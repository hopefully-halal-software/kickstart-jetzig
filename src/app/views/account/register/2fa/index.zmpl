<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>idz register 2fa verification</title>
  <link href="/bismi_allah_login.css" rel="stylesheet">
</head>
<body>
  <main>
    <h1>email verification code for {{ .email_sensored }}</h1>

    <form method="post" action="#">
      {{context.authenticityFormElement()}}
      <input type="text" name="code_2fa" />
      <nav>
        <button type="submit">confirm</button>
        <div></div>
      </nav>
    </form>
  </main>
</body>
</html>
