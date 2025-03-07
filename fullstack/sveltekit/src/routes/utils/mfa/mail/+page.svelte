<script>
  let { data } = $props();

  import { fetchToast } from '$lib/CustomFetch';
  import { goto } from '$app/navigation';

  const params = $state({
    data: data.encrypted_data,
    code_2fa: '',
  })

  function onsubmit(event) {
    event.preventDefault();
    fetchToast('/api/v1/auth/mfa/mail.json', params).then((r_json) => {
      goto(r_json.path);
    }).catch(() => {});
  }
</script>

<form {onsubmit} class="card border-[1px] border-neutral-500 preset-filled-surface-100-900 w-full max-w-md space-y-4 p-4 mx-auto mt-32">
    <h1 class="text-2xl text-center">Email Verification</h1>
    <label class="label">
	<span class="label-text">Verification Code</span>
	<input class="input" type="text" name="code_2fa" placeholder="XXXXXXXX" bind:value={params.code_2fa} />
    </label>

    <fieldset class="flex justify-end">
	<!-- Button -->
        <button type="submit" class="btn preset-filled-primary-500">
            Confirm
        </button>
    </fieldset>
</form>

