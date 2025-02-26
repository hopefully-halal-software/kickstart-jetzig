<script>
	let { data } = $props();
</script>

<form action="#" method="POST" class="card border-[1px] border-neutral-500 preset-filled-surface-100-900 w-full max-w-md space-y-4 p-4 mx-auto md:my-48 my-12">
    <input type="text" name="data" value={data.encrypted_data} hidden />
    <label class="label">
	<span class="label-text">Verification Code</span>
	<input class="input" type="text" name="code_2fa" placeholder="XXXXXXXX" />
    </label>

    <fieldset class="flex justify-end">
	<!-- Button -->
        <button type="submit" class="btn preset-filled-primary-500">
            Confirm
        </button>
    </fieldset>
</form>

