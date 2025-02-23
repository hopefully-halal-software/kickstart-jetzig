<script>
	// بسم الله الرحمن الرحيم
	// la ilaha illa Allah Mohammed Rassoul Allah
	import { TagsInput } from '@skeletonlabs/skeleton-svelte';

	// State
	let flavors = $state(['Vanilla', 'Chocolate', 'Strawberry']);
</script>

<button class="btn preset-filled">بسم الله الرحمن الرحيم</button>

<TagsInput name="example" bind:value={flavors} placeholder="Add Tag..." />
