<script>
  import { Switch } from '@skeletonlabs/skeleton-svelte';
  // Icons
  import IconMoon from 'lucide-svelte/icons/moon';
  import IconSun from 'lucide-svelte/icons/sun';

  // Bind to the checked state
  let mode = $state(false);

  {
    const darkMode = (() => {
      if (typeof localStorage !== 'undefined' && localStorage.getItem('darkMode')) return localStorage.getItem('darkMode');
      if (window.matchMedia('(prefers-color-scheme: dark)').matches) return 'dark';
        return 'dark';
    })();

    if (darkMode === 'light') {
      document.documentElement.classList.remove('dark');
    } else {
      document.documentElement.classList.add('dark');
    }

    mode = 'dark' !== darkMode;
  }

  // Handle the change in state when toggled.
  function handleModeChange() {
    const element = document.documentElement;
    element.classList.toggle('dark');

    const isDark = element.classList.contains('dark');
    localStorage.setItem('darkMode', isDark ? 'dark' : 'light');

    mode = !mode;
  }
</script>

<Switch name="mode" controlActive="bg-surface-200" bind:checked={mode} onCheckedChange={handleModeChange}>
  {#snippet inactiveChild()}<IconMoon size="14" />{/snippet}
  {#snippet activeChild()}<IconSun size="14" />{/snippet}
</Switch>
