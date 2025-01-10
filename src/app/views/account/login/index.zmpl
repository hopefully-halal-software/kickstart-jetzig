  <link href="/bismi_allah_form.css" rel="stylesheet">
    <form method="post" action="#">
      {{context.authenticityFormElement()}}
      <input type="text" name="login" placeholder="login" required>
      <input type="text" name="email" placeholder="email" required>
      <input type="password" name="password" placeholder="password" required>
      <nav>
        <button type="submit">login</button>
        <a href="/account/register">register</a>
      </nav>
    </form>
