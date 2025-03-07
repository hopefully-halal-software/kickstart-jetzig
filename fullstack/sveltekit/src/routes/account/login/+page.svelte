<script>
  import { goto } from '$app/navigation';
  import { fetchToast } from '$lib/CustomFetch';

  let { data } = $props();

  const params = $state({
    email: '',
    password: '',
  });

  function onsubmit(event) {
    event.preventDefault();
    fetchToast('/api/v1/account/login.json', params).then((r_json) => {
      goto(r_json.path + '?data=' + r_json.data);
    }).catch(() => {});
  }

</script>

<form {onsubmit} class="card border-[1px] border-neutral-500 preset-filled-surface-100-900 w-full max-w-md space-y-4 p-4 mx-auto mt-32">
	<h1 class="text-2xl text-center">Login to your account</h1>
	<label class="label">
		<span class="label-text">Email</span>
		<input class="input" type="text" name="email" placeholder="bismi-allah@alhamdo-li-allah.com" bind:value={params.email}/>
	</label>

	<label class="label">
		<span class="label-text">Password</span>
		<input class="input" type="password" name="password" placeholder="******"  bind:value={params.password}/>
	</label>

	<fieldset class="flex justify-between">
        <a class="text-secondary-500 underline" href="/account/recovery">
            forgot passwoord?
        </a>

		<!-- Button -->
		<button type="submit" class="btn preset-filled-primary-500">
            Login
        </button>
	</fieldset>

	<hr class="hr border-t-2" />

    <p class="flex justify-between">
        <span>don't have an account?</span>
        <a href="/account/register" class="font-semibold text-indigo-600 hover:text-indigo-500">
            Register
        </a>
    </p>
</form>
