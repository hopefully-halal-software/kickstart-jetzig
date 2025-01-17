<section id="account-info">
    <h3 class="section-title">معلومات حسابك</h3>
    <p><span class="account-info-title">الإسم:</span> <span class="account-info-text">{{ .user.name }}</span></p>
    <p><span class="account-info-title">البريد الإلكتروني:</span> <span class="account-info-text">{{ .user.email }}</span></p>
    <p><span class="account-info-title">المعرف:</span> <span class="account-info-text">{{ .user.id }}</span></p>

    <form action="/account/logout" method="post">{{context.authenticityFormElement()}}<button>تسجيل الخروج</button></form>
</section>
