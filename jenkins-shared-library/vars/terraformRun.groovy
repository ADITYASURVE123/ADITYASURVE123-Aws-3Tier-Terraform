// Optional Jenkins Shared Library step.
// Configure: Manage Jenkins > System > Global Trusted Pipeline Libraries (name: tf-lib, point at this folder's repo).
// Usage in a Jenkinsfile:
//   @Library('tf-lib') _
//   terraformRun(env: 'dev', args: 'validate')
def call(Map cfg = [:]) {
  String dir = cfg.dir ?: "environments/${cfg.env}"
  sh "terraform -chdir=${dir} ${cfg.args}"
}
