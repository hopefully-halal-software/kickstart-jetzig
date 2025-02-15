<script>
	import '../app.css';
	let { children } = $props();
</script>

<header>
	<nav class="font-semibold text-xl text-center">
		<a href="/">Home</a>
		<a class="ml-2" href="/account">Account</a>
	</nav>
</header>

{@render children()}
