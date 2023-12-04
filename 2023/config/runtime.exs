import Config
import Dotenvy

Dotenvy.source!([".env", System.get_env()])

Config.config(:aoc, cookie: env!("AOC_COOKIE", :string, nil))
