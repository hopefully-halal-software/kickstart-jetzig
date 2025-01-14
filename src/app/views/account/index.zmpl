<section id="account-info">
    <h3 class="section-title">your account info</h3>
    <p><span class="account-info-title">name:</span> <span class="account-info-text">{{ .user.name }}</span></p>
    <p><span class="account-info-title">email:</span> <span class="account-info-text">{{ .user.email }}</span></p>
    <p><span class="account-info-title">id:</span> <span class="account-info-text">{{ .user.id }}</span></p>

    <form action="/account/logout" method="post">{{context.authenticityFormElement()}}<button>disconnect</button></form>
</section>
