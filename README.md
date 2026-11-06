# anubis-nginx-runner

Easily set up, build, and run a customized [Anubis](https://github.com/TecharoHQ/anubis) Docker image
in front of your websites served by nginx. Prevents AI scrapers, crawlers, and other bots by requiring
to pass a check before they get to your website.

Anubis is built from source and customized with its own look, depending on how you want it look and run.
Modify the images and theme files to get the look you want, then build and start the service.

---

## How it works

```text
visitor -> nginx :443 -> Anubis 127.0.0.1:8923 -> nginx 127.0.0.1:8081 -> your site
```

- nginx handles HTTPS and passes every request to Anubis.
- Anubis challenges browsers, blocks known AI crawlers, and passes approved
  visitors back to nginx, which serves the site.
- Anubis and the internal listener only listen on `127.0.0.1`, so nothing
  outside the server can reach them directly.
- If Anubis is down, nginx serves the site directly without passing Anubis checks, so the site
  stays up.


## Requirements
- Linux server with nginx configured and running
- Docker
- HTTPS certifcates for your website domain

## Setup
1. Configure your settings in `anubis.env`. Set your hostnames:
   ```text
   ANUBIS_REDIRECT_DOMAINS=example.com,www.example.com
   ```
2. Setup your nginx server for anubis. Use the provided nginx example config files to set your server up properly. Once config is setup, reload your nginx server.
    1. For static sites, use the `static-site-example.conf` nginx file as a template.
    2. For apps/services, use the `service-example.conf` nginx file as a template.
3. **Build and start Anubis.**

   ```bash
   ./build.sh && ./start.sh
   ```
4. Check to to see if its running and works on your website. Open your site on a new and clean browser session, and you should see your customized Anubis page show up and challange your browser. You can use `metrics.sh` to see the visits that Anbuis challanged and get a summary of what ANubis has blocked, challanged, and allowed.
5. **Optional**: You can also use `metrics-cron.sh` to create a cron job that runs every 15 mins and logs its metrics and tracks Anubis across time.

## Contributing
Thanks for taking the time to contribute to the repo! Any and all contributions are welcome, including bug reporting, enhancements, feature requests, and PRs.

If you found a bug and want to report it or want to add a new feature, [create an issue](https://github.com/wfar/anubis-nginx-runner/issues/) with clear details of the problem to start a discussion. If a change is warranted, clone/fork the repo to start developing and create a PR for review.

## License
Distributed under the MIT License, see [License](LICENSE). Anubis license can be found [here](https://github.com/TecharoHQ/anubis/blob/main/LICENSE).
