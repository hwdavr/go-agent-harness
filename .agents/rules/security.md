# Backend security rules

- Validate issuer, audience, algorithm, signature, and expiry for JWTs.
- Read user identity from verified claims only; never accept a caller-supplied
  user ID as the ownership authority.
- Treat email claims as untrusted input: normalize only for lookup and do not
  log them.
- Never log authorization headers, tokens, raw claims, note content, database
  URLs, or full request bodies.
- Keep CORS and bind-address changes explicit and reviewable.
- Use parameterized SQL and enforce ownership/access checks before mutations.
- A security-sensitive change requires a focused negative test (for example,
  wrong audience, missing token, or cross-user access).
