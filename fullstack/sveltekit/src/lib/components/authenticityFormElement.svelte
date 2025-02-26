<script>
  let { data } = $props();
  const xcsrf = data.xcsrf;
</script>

<input type="hidden" name={xcsrf.name} value={xcsrf.value} />
