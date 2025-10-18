export const useApi = (endpoint: string, opts: any = {}) => {
    const base = useRuntimeConfig().public.apiUrl;
    return $fetch(`${base}${endpoint}`, opts)
}