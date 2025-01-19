  <link href="/bismi_allah_form.css" rel="stylesheet">
    <form method="post" action="#">
      {{context.authenticityFormElement()}}
      <input type="email" name="email" placeholder="email" required>
      <input type="password" name="password" placeholder="password" required>
      <nav>
        <button type="submit">إعادة تعيين كلمة المرور</button>
        <a href="/account/register">إنشاء حساب</a>
        <a href="/account/login">تسجيل الدخول</a>
      </nav>
    </form>
