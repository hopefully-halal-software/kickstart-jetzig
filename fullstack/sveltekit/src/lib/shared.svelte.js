// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

export let global = $state({
    // { name: '', email: '', registred_at: '' }
    user: null,
    // { name: '', value: '' }
    xcsrf: null,
});

export async function fetchUser() {
  if(global.user) return global.user;

  if(sessionStorage.user) {
    global.user = JSON.parse(sessionStorage.user);
    return global.user;
  }

  const response = await window.fetch('/api/v1/account/info.json');

  if (!response.ok) {
    if(401 === response.status) return null;
    throw new Error(`Failed to fetch account information: status ${response.status}`);
  }

  const data = await response.json();

  // Assuming the structure of the response looks like this:
  global.user = data.user;
  sessionStorage.user = JSON.stringify(global.user);

  return global.user;
}

export async function fetchXcsrfToken() {
  if(global.xcsrf) return { xcsrf: global.xcsrf };

  if(sessionStorage.xcsrf) {
    global.xcsrf = JSON.parse(sessionStorage.xcsrf);
    return global.xcsrf;
  }

  const response = await fetch('/api/v1/auth/tokens/ani-csrf.json');

  if (!response.ok) {
    throw new Error('Failed to get xcsrf token');
  }

  const data = await response.json();

  global.xcsrf = { name: data.name, value: data.value };
  sessionStorage.xcsrf = JSON.stringify(global.xcsrf);

  return global.xcsrf;
}

export function removeUser() {
  global.user = null;
  sessionStorage.removeItem('user');
}

export function removeXcsrfToken() {
  global.xcsrf = null;
  sessionStorage.removeItem('xcsrf');
}

