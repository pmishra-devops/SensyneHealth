if (process.env.FAIL_THE_TESTS == 1) {
	console.log("the tests failed.")
	process.exit(1)

} else {
	console.log("the tests passed")
	process.exit(0)
}

