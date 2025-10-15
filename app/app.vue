<template>
  <div class="relative dir-rtl">
    <!-- Top Menu -->
    <MenuLogo />
    <Menu />

    <!-- ✅ Loader runs only in the browser -->
    <ClientOnly>
      <MainLoading
          v-if="showLoader"
          ref="mainLoading"
          @done="onLoadingDone"
      />
    </ClientOnly>

    <!-- ✅ Page stays hidden until loading animation is done -->
    <div
        :class="{
        'opacity-0 pointer-events-none': showLoader,
        'opacity-100 pointer-events-auto': !showLoader
      }"
        class="transition-opacity duration-700"
    >
      <NuxtLayout>
        <NuxtPage />
      </NuxtLayout>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, nextTick } from 'vue'
import { useHead, useRoute } from '#imports'
import {setAppLocale} from '~/services/preference'

const route = useRoute()
const store = useGlobalStore()
const {getLoadingType} = storeToRefs(store)

const showLoader = ref(true)
const pageLine = ref(null)

/* ✅ Handle favicon based on browser theme */
const updateFavicon = () => {
  if (!process.client) return
  const isDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches
  const favicon = isDarkMode ? '/light-favicon.ico' : '/dark-favicon.ico'

  useHead({
    link: [
      {rel: 'icon', type: 'image/x-icon', href: favicon}
    ]
  })
}

/* ✅ Watch route changes for line loading */
watch(
    () => [route.fullPath, getLoadingType.value],
    async ([path, type]) => {
      if (type === 'line') {
        await nextTick()
        if (pageLine.value?.init) {
          try {
            pageLine.value.init()
            console.log(`✅ CommonLineWrapper init executed for ${path}`)
          } catch (err) {
            console.warn('⚠️ Error in CommonLineWrapper init', err)
          }
        } else {
          console.warn('⚠️ CommonLineWrapper not mounted yet')
        }
      }
    },
    {immediate: true}
)

/* ✅ When loading animation finishes */
const onLoadingDone = () => {
  showLoader.value = false
}

/* ✅ Mounted logic (runs only in browser) */
onMounted(() => {
  if (process.client) {
    const langValue = localStorage.getItem('lang') || 'fa'
    store.setLocale(langValue)
    setAppLocale(langValue)

    // prevent double-tap zoom on mobile
    const preventDoubleClickZoom = (e) => e.preventDefault()
    document.addEventListener('dblclick', preventDoubleClickZoom, {passive: false})

    updateFavicon()
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', updateFavicon)
  }
})
</script>

<style>
html, body {
  /* Optional: disable unwanted gestures or selections */
  /* touch-action: manipulation;
  -webkit-touch-callout: none;
  user-select: none; */
}
</style>
