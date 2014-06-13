@test "check for LoopBack install" {
  export welcome="Welcome to the LoopBack sample application"
  wget -O - http://localhost:3000 | grep "${welcome}"
}
