<div class="flex min-h-full flex-col justify-center px-6 py-12 lg:px-8 border rounded-lg shadow-2xl mx-2 md:m-auto lg:w-1/2 md:w-3/4 lg:px-8">
  <div class="sm:mx-auto sm:w-full sm:max-w-sm">
    <img class="mx-auto h-10 w-auto" src="/logo.png" alt="logo">
    <h2 class="mt-10 text-center text-2xl/9 font-bold tracking-tight text-gray-900">
      رمز التأكد من البريد الإلكتروني: {{ .email_sensored }}
    </h2>
  </div>

    <div class="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
        <form method="post" action="#" class="m-auto space-y-6">
        {{context.authenticityFormElement()}}
        <input type="hidden" name="data" value={{ .data }} />
        
        <div>
            @partial partials/information/label("code", "رمز التأكيد", "font-semibold")
            @partial partials/input/input("code", "text", "code_2fa", "", "رمز التأكيد", "", "required")
        </div>

        <div>
            @partial partials/input/button("تأكيد", "submit")
        </div>
    
        </form>
    </div>
</div>
