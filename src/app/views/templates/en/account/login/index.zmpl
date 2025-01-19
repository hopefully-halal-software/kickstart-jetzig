  <link href="/bismi_allah_form.css" rel="stylesheet">
    <form method="post" action="#">
      {{context.authenticityFormElement()}}
      <input type="email" name="email" placeholder="email" required>
      <input type="password" name="password" placeholder="password" required>
      <nav>
        <button type="submit">login</button>
        <a href="/account/register">register</a>
        <a href="/account/recovery">forgot your password?</a>
      </nav>
    </form>
