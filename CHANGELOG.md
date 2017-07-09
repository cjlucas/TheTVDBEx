1.1.1
=====
- `Auth.Server.refresh_token` now returns an error on failure

1.1.0
=====
- `Series.episodes/1` now returns a list instead of an `Enumerable`
- `User.ratings` now returns a list instead of an `Enumerable`

1.0.1
=====
- Fixes an issue where `TheTVDB.authenticate` returns `:ok` if `user_name` is empty [#5]
