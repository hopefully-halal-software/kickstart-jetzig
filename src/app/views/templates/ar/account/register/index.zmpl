  <link href="/bismi_allah_form.css" rel="stylesheet">
    <form method="post" action="#">
      {{context.authenticityFormElement()}}
      <input type="text" name="name" placeholder="name" required>
      <input type="text" name="email" placeholder="email" required>
      <input type="password" name="password" placeholder="password" required>
      <nav>
        <button type="submit">إنشاء حساب</button>
        <a href="/account/login">تسجيل الدخول</a>
      </nav>
    </form>
