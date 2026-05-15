export function normalizeUrl(input: string): string {
  try {
    const u = new URL(input);
    u.hash = "";
    u.username = ""; // H3: credentials strip
    u.password = ""; // H3: credentials strip
    u.protocol = u.protocol.toLowerCase();
    // host: URL 객체가 자동으로 lowercase
    let path = u.pathname;
    if (path !== "/" && path.endsWith("/")) {
      path = path.slice(0, -1);
    }
    u.pathname = path;
    return u.toString();
  } catch {
    return input;
  }
}
