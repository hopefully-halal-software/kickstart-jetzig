  <link href="/bismi_allah_form.css" rel="stylesheet">
    <h1>email verification code for {{ .email_sensored }}</h1>

    <form method="post" action="#">
      {{context.authenticityFormElement()}}
      <input type="text" name="code_2fa" />
      <nav>
        <button type="submit">confirm</button>
        <div></div>
      </nav>
    </form>
