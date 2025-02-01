<div id="account-info" class="p-4 border rounded-lg shadow-2xl mx-2 md:m-auto lg:w-1/2 md:w-3/4 lg:px-8">
    <h3 class="text-2xl font-bold text-center" >Your Accoun info</h3>
    <p class="mt-8"><span class="font-semibold text-lg">Name:</span> <span class="text-gray-900">{{ .user.name }}</span></p>
    <p class="mt-2"><span class="font-semibold text-lg">Email:</span> <span class="text-gray-900">{{ .user.email }}</span></p>
    <p class="mt-2"><span class="font-semibold text-lg">id:</span> <span class="text-gray-900">{{ .user.id }}</span></p>

    <form action="/account/logout" method="post">
        {{context.authenticityFormElement()}}
        @partial partials/input/button("Logout", "submit", "mt-8")
    </form>
</div>
