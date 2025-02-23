<script>
	import '../app.css';

	import LightSwitch from '$lib/components/LightSwitch.svelte';


    import IconMenu from 'lucide-svelte/icons/menu';
    import IconX from 'lucide-svelte/icons/x';

    let isOpen = $state(false);

	const links = [
		{ name: 'Home', href: '/' },
		{ name: 'Account', href: '/account' },
	];

	let { children } = $props();
</script>

<header class="w-full bg-surface-100 dark:bg-surface-900 shadow-md">
    <nav class="container mx-auto px-4 py-4 flex justify-between items-center">
        <!-- Logo -->
        <a href="/" class="text-xl font-bold text-primary">
            <img src="/favicon.png" alt="icon" class="size-12">
        </a>

        <!-- Desktop Navigation -->
        <ul class="hidden md:flex gap-6 text-lg">
            <li><a href="/account" class="hover:text-primary">Account</a></li>
            <li><a href="/" class="hover:text-primary">Pricing</a></li>
            <li><a href="/" class="hover:text-primary">Contact</a></li>
        </ul>

        <!-- Mobile Menu Button -->
        <button class="md:hidden" onclick={() => (isOpen = true)}>
            <IconMenu size="24" />
        </button>
    </nav>

    {#if isOpen}
    <div class="fixed inset-0 bg-black/50 z-40" onclick={() => (isOpen = false)}>dnjdfndsjnj</div>
    <div class="fixed top-0 left-0 w-64 h-full bg-surface-100 dark:bg-surface-900 z-50">
        <button class="btn" onclick={() => (isOpen = false)}>
            <IconX size="24" />
        </button>
        <ul class="flex flex-col gap-4 text-lg">
            <li><a href="#" class="hover:text-primary" onclick={() => (isOpen = false)}>Features</a></li>
            <li><a href="#" class="hover:text-primary" onclick={() => (isOpen = false)}>Pricing</a></li>
            <li><a href="#" class="hover:text-primary" onclick={() => (isOpen = false)}>Contact</a></li>
        </ul>
        <LightSwitch />
    </div>
{/if}

</header>


<main>
{@render children()}
</main>
