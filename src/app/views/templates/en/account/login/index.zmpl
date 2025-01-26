<div class="flex min-h-full flex-col justify-center px-6 py-12 lg:px-8 border rounded-lg shadow-2xl mx-2 md:m-auto lg:w-1/2 md:w-3/4 lg:px-8">
  <div class="sm:mx-auto sm:w-full sm:max-w-sm">
    <img class="mx-auto h-10 w-auto" src="/logo.png" alt="logo">
    <h2 class="mt-10 text-center text-2xl/9 font-bold tracking-tight text-gray-900">
        Login
    </h2>
  </div>

    <div class="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
        <form method="post" action="#" class="m-auto space-y-6">
        {{context.authenticityFormElement()}}
        
        <div>
            @partial partials/information/label("email", "Email", "font-semibold")
            @partial partials/input/input("email", "email", "email", "", "email", "", "required")
        </div>
    
        <div>
            <div class="flex items-center justify-between">
                @partial partials/information/label("password", "Password", "font-semibold")
                <div class="text-sm">
                    <a href="/account/recovery" class="font-semibold text-indigo-600 hover:text-indigo-500">Forgot password?</a>
                </div>
            </div>
            @partial partials/input/input("password", "password", "password", "", "password", "", "required")
        </div>
    
        <div>
            @partial partials/input/button("login", "submit")
        </div>
    
        <div>
            <span>don't have an account?</span>
            <a href="/account/register" class="font-semibold text-indigo-600 hover:text-indigo-500">
                Register
            </a>
        </div>
    
        </form>
    </div>
</div>
