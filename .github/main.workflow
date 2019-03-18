workflow "web app maven build  test" {
  on = "push"
  resolves = [
    "GitHub Action for Maven-1",
    "GitHub Action for Maven",
  ]
}

action "GitHub Action for Maven" {
  uses = "LucaFeger/action-maven-cli@9d8f23af091bd6f5f0c05c942630939b6e53ce44"
  runs = "mvn clean install"
}

action "GitHub Action for Maven-1" {
  uses = "LucaFeger/action-maven-cli@9d8f23af091bd6f5f0c05c942630939b6e53ce44"
  runs = "mvn clean test"
}
