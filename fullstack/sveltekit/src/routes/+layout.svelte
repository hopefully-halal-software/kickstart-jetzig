<script>
    import '../app.css';

    import { Toaster } from 'svelte-sonner';
    import LightSwitch from '$lib/components/LightSwitch.svelte';

    import IconMenu from 'lucide-svelte/icons/menu';
    import IconX from 'lucide-svelte/icons/x';

    let menu_open = $state(false);

    const links = [
        { name: 'Home', href: '/' },
	{ name: 'Account', href: '/account' },
    ];

    let { children } = $props();
</script>

<header class="sticky top-0 z-10 w-full backdrop-blur-xs bg-surface-100 dark:bg-surface-900 shadow-md">
    <nav class="container mx-auto px-4 py-4 flex justify-between items-center">
        <!-- Logo -->
        <a href="/" class="text-xl font-bold text-primary">
            <img src="/favicon.png" alt="icon" class="size-12">
        </a>

        <!-- Desktop Navigation -->
        <ul class="hidden md:flex gap-6 text-lg">
            {#each links as _link}
                <li><a href={_link.href} class="hover:text-primary">{_link.name}</a></li>
            {/each}
            <LightSwitch />
        </ul>

        <!-- Mobile Menu Button -->
        <button class="md:hidden" onclick={() => (menu_open = true)}>
            <IconMenu size="24" />
        </button>
    </nav>

    {#if menu_open}
    <button aria-label="Open menu" class="fixed inset-0 bg-black/50 z-40" onclick={() => (menu_open = false)}></button>
    <div class="fixed top-0 left-0 w-64 h-full bg-surface-100 dark:bg-surface-900 z-50">
        <button class="btn" onclick={() => (menu_open = false)}>
            <IconX size="24" />
        </button>
        <ul class="flex flex-col gap-4 text-lg">
            {#each links as _link}
                <li><a href={_link.href} class="hover:text-primary">{_link.name}</a></li>
            {/each}
        </ul>
        <LightSwitch />
    </div>
{/if}

</header>
<Toaster richColors position="top-center" />

<main>
{@render children()}
</main>
