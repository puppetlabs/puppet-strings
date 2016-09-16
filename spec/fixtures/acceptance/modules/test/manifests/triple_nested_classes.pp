# Testing tested classes
# docs stuff
# @param nameservers [String] Don't ask me what this does!
# @param default_lease_time [Integer[1024, 8192]] text goes here
# @param max_lease_time does stuff
class outer (
		$dnsdomain,
		$nameservers,
		$default_lease_time = 3600,
		$max_lease_time     = 86400
		) {
	# @param options [String[5,7]] gives user choices
	# @param multicast [Boolean] foobar
	# @param servers yep, that's right
	class middle (
      $options   = "iburst",
      $servers,
      $multicast = false
    ) {
    class inner (
        $choices   = "uburst",
        $secenekler   = "weallburst",
        $boxen,
        $manyspell = true
      ) {}
    }
}
