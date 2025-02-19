<script>
  // import type { Route } from "@mateothegreat/svelte5-router";
  import { route, Router } from "@mateothegreat/svelte5-router";
  import Home from './pages/Home.svelte';
  import Account from "./pages/Account.svelte";
  import Login from "./pages/account/Login.svelte";
  import Mail from "./pages/utils/mfa/Mail.svelte";

  const routes = [
    {
      path: "^/$",
      component: Home
    },
    {
      path: "(account/login)",
      component: Login
    },
    {
      path: "(account)",
      component: Account
    },
    {
      path: "(utils/mfa/mail)",
      component: Mail
    },
    // {
    //   path: "/params/(?<route>.*)/(?<subhana_allah>.*)",
    //   component: Params
    // },
  ];
</script>

<div class="flex gap-2">
  <a use:route href="/">Home</a>
  <a use:route href="/account">Account</a>
  <a use:route href="/account/login">Login</a>
  <a use:route href="/utilts/mfa/mail">mail</a>
</div>

<Router basePath="/" {routes} />

