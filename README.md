# Spectator::ContextHelper

[![test](https://github.com/masaakiaoyagi/spectator-context_helper.cr/actions/workflows/test.yml/badge.svg)](https://github.com/masaakiaoyagi/spectator-context_helper.cr/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This helper library is for writing tests concisely.

You can write a test as follows.
```crystal
example_with "value is zero", value: 0 { expect(value).to eq 0 }
```
Above is the same as below.
```crystal
context "value is zero" do
  let(:value) { 0 }
  it { expect(value).to eq 0 }
end
```

That's basically all there is to it, but I think it will be more potent when used with a [custom matcher](https://gitlab.com/arctic-fox/spectator/-/wikis/Custom-Matchers).

## Installation

1. Add the dependency to your `shard.yml`:

    ```yaml
    development_dependencies:
      spectator-context_helper:
        github: masaakiaoyagi/spectator-context_helper.cr
    ```

1. Run `shards install`

## Usage

```crystal
require "spectator-context_helper"
```

See [spec](https://github.com/masaakiaoyagi/spectator-context_helper.cr/blob/main/spec/spectator/context_helper_spec.cr) how to write a test.

## Development

### Run tests
```sh
$ docker compose run --rm 1.4 crystal spec
```

## See also
* [Spectator](https://gitlab.com/arctic-fox/spectator)
* [Ruby version](https://github.com/masaakiaoyagi/rspec-context_helper.rb)
