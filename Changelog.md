# Changelog

## 0.2.0

- Rails 7 / 8 compatibility. Modern ActiveRecord calls `connection` from within the `inherited`
  hook chain (before it has set `@base_class`), and some extensions (e.g. torque-postgresql's
  `physically_inherited?`) do the same, so `include_when_connected` could fire while a subclass was
  still mid-definition and blow up any concern that inspects the schema. Pending includes are now
  skipped while a class's `@base_class` is unset, applied at the end of the `inherited` hook once
  the class is fully defined, and guarded against re-entrancy (an included concern calling
  `connection` again).
- Loosened the `activerecord` / `activesupport` dependency cap (was `< 5.3`).

## 0.1.0

- Initial release.
