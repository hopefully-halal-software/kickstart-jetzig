<script>
	let { data } = $props();
</script>

<div class="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
    <form method="post" action="#" class="m-auto space-y-6">
        <input type="text" name="data" value={data.encrypted_data} hidden />
        <div>
            <label for="code" class="block text-sm/6 text-gray-900 font-semibold">verification code</label>
            <input id="code" type="text" name="code_2fa" value="" placeholder="verification code" class="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6 " required/>
        </div>

        <div>
            <button type="submit" class="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-1.5 text-sm/6 font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 " > Confirm </button>
        </div>
    
    </form>
</div>
