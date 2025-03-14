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
    fetchToast('/api/v1/account/recovery.json', params).then((r_json) => {
      goto(r_json.path + '?data=' + r_json.data);
    }).catch(() => {});
  }
</script>
<form {onsubmit} class="card border-[1px] border-neutral-500 preset-outlined-surface-200-800 w-full max-w-lg space-y-4 p-4 mx-auto mt-12">
	<h1 class="text-2xl text-center">Recover your Account</h1>
	<label class="label">
		<span class="label-text">Email</span>
		<input class="input" type="text" name="email" placeholder="bismi-allah@alhamdo-li-allah.com" bind:value={params.email}/>
	</label>

	<label class="label">
		<span class="label-text">New Password</span>
		<input class="input" type="password" name="password" placeholder="******" bind:value={params.password}/>
	</label>

	<fieldset class="flex justify-end">
		<!-- Button -->
	  <button type="submit" class="btn preset-filled-primary-500">
            Confirm
          </button>
	</fieldset>
</form>
