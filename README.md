# `Supabase Flutter`

Monorepo containing all [Supabase](https://supabase.com/) libraries for Flutter.

- [supabase_flutter](https://github.com/supabase/supabase-flutter/tree/main/packages/supabase_flutter) - Flutter client for Supabase.
- [supabase](https://github.com/supabase/supabase-flutter/tree/main/packages/supabase) - Dart client library for Supabase. Use this for non-Flutter projects.
- [postgrest](https://github.com/supabase/supabase-flutter/tree/main/packages/postgrest) - Sub-library of `supabase` for calling PostgREST endpoints.
- [gotrue](https://github.com/supabase/supabase-flutter/tree/main/packages/gotrue) - Sub-library of `supabase` for calling GoTrue endpoints.
- [realtime_client](https://github.com/supabase/supabase-flutter/tree/main/packages/realtime_client) - Sub-library of `supabase` for subscribing to realtime changes.
- [storage_client](https://github.com/supabase/supabase-flutter/tree/main/packages/storage_client) - Sub-library of `supabase` for interacting with Supabase Storage.
- [functions_client](https://github.com/supabase/supabase-flutter/tree/main/packages/functions_client) - Sub-library of `supabase` for interacting with Supabase Edge Functions.
- [yet_another_json_isolate](https://github.com/supabase/supabase-flutter/tree/main/packages/yet_another_json_isolate) - A library to parse JSON in a separate isolate.

Documentation 📖: https://supabase.com/docs/reference/dart/introduction

## Using the packages locally

This repo is a monorepo managed using [Melos](https://melos.invertase.dev/).

Bootstrap the packages by linking the local packages and installing any remote dependencies by running the following:

```bash
melos bs
```

You should now be able to add `supabase_flutter` to your `pubspec.yaml` by specifying the local path and import the libraries locally.

## Contributing

- Fork the repo on [GitHub](https://github.com/supabase/supabase-flutter)
- Clone the project to your own machine
- Commit changes to your own branch
- Push your work back up to your fork
- Submit a Pull request so that we can review your changes and merge

## License

This repo is licenced under MIT.

## Resources

- [Quickstart: Flutter](https://supabase.com/docs/guides/with-flutter)
- [Flutter Tutorial: building a Flutter chat app](https://supabase.com/blog/flutter-tutorial-building-a-chat-app)
- [Flutter Tutorial - Part 2: Authentication and Authorization with RLS](https://supabase.com/blog/flutter-authentication-and-authorization-with-rls)
