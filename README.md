# hubot-new-relic-alerts [![Build Status](https://img.shields.io/travis/catops/hubot-new-relic-alerts.svg?maxAge=2592000&style=flat-square)](https://travis-ci.org/catops/hubot-new-relic-alerts) [![npm](https://img.shields.io/npm/v/hubot-new-relic-alerts.svg?maxAge=2592000&style=flat-square)](https://www.npmjs.com/package/hubot-new-relic-alerts)

:cat: A hubot script to tell your team of today's New Relic warnings and violations

See [`src/new-relic-alerts.coffee`](src/new-relic-alerts.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-new-relic-alerts --save`

Then add **hubot-new-relic-alerts** to your `external-scripts.json`:

```json
["hubot-new-relic-alerts"]
```

## Sample Interaction

```
hubot>> Daily performance update! There are 5 performance warnings and 1 performance policy violations today. Check them out at https://alerts.newrelic.com/
```

## Contributing

Please read our general [contributing guidelines](CONTRIBUTING.md).

## Open source licensing info
1. [TERMS](TERMS.md)
2. [LICENSE](LICENSE)
3. [CFPB Source Code Policy](https://github.com/cfpb/source-code-policy/)
