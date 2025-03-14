<script>
  import { goto } from '$app/navigation';
  import { fetchToast } from '$lib/CustomFetch';

  let { data } = $props();

  const params = $state({
    name: '',
    email: '',
    password: '',
  });

  function onsubmit(event) {
    event.preventDefault();
    fetchToast('/api/v1/account/register.json', params).then((r_json) => {
      goto(r_json.path + '?data=' + r_json.data);
    }).catch(() => {});
  }
</script>
<form {onsubmit} class="card border-[1px] border-neutral-500 preset-outlined-surface-200-800 w-full max-w-lg space-y-4 p-4 mx-auto mt-12">
	<h1 class="text-2xl text-center">Register</h1>
	<label class="label">
		<span class="label-text">Name</span>
		<input class="input" type="text" name="name" placeholder="Abdu Allah" bind:value={params.name}/>
	</label>

	<label class="label">
		<span class="label-text">Email</span>
		<input class="input" type="text" name="email" placeholder="bismi-allah@alhamdo-li-allah.com" bind:value={params.email} />
	</label>

	<label class="label">
		<span class="label-text">Password</span>
		<input class="input" type="password" name="password" placeholder="******" bind:value={params.password} />
	</label>

	<fieldset class="flex justify-end">
		<!-- Button -->
		<button type="submit" class="btn preset-filled-primary-500">
			Register
		</button>
	</fieldset>

	<hr class="hr border-t-2" />

    <p class="flex justify-between">
        <span>already have an account?</span>
        <a href="/account/login" class="font-semibold text-indigo-600 hover:text-indigo-500">
            Login
        </a>
    </p>
</form>
