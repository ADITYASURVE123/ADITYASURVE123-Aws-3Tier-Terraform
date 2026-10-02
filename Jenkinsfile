// Declarative multibranch pipeline for the 3-tier Terraform project.
// AWS access comes from the Jenkins EC2 instance profile - no keys in Jenkins.

def tf(String args) {
  sh "terraform -chdir=${env.TF_DIR} ${args}"
}

def notify(String status) {
  def msg = "${status}: ${env.JOB_NAME} #${env.BUILD_NUMBER} (${params.ENVIRONMENT}/${params.ACTION}) ${env.BUILD_URL}"
  try {
    mail to: env.NOTIFY_EMAIL, subject: "[Jenkins] ${status} ${env.JOB_NAME}", body: msg
  } catch (Throwable t) {
    echo "Email skipped: ${t.message}"
  }
  try {
    withCredentials([string(credentialsId: 'slack-webhook', variable: 'HOOK')]) {
      sh "curl -s -X POST -H 'Content-type: application/json' --data '{\"text\":\"${msg}\"}' \"\$HOOK\""
    }
  } catch (Throwable t) {
    echo "Slack skipped: ${t.message}"
  }
}

pipeline {
  agent any

  parameters {
    // First choice is the default. Feature branches / PRs never get past 'plan' anyway.
    choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Target environment')
    choice(name: 'ACTION', choices: ['apply', 'plan', 'destroy'], description: 'apply/destroy only run on main')
    booleanParam(name: 'RUN_INFRACOST', defaultValue: false, description: 'Cost estimate (needs infracost + credential infracost-api-key)')
  }

  options {
    ansiColor('xterm')
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timeout(time: 60, unit: 'MINUTES')
  }

  environment {
    AWS_REGION = 'ap-south-1'
    AWS_DEFAULT_REGION = 'ap-south-1'
    TF_IN_AUTOMATION = 'true'
    TF_INPUT = '0'
    TF_DIR = "environments/${params.ENVIRONMENT}"
    NOTIFY_EMAIL = 'you@example.com'
    // Example of the credentials() helper (create the credential first, then uncomment):
    // SLACK_WEBHOOK = credentials('slack-webhook')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'terraform version && tflint --version && tfsec --version && git --version'
        sh 'aws sts get-caller-identity'
      }
    }

    stage('Format Check') {
      steps {
        sh 'terraform fmt -check -recursive -diff'
      }
    }

    stage('Init') {
      steps {
        sh "bash scripts/init.sh ${params.ENVIRONMENT}"
      }
    }

    stage('Validate') {
      steps {
        tf 'validate'
      }
    }

    stage('TFLint') {
      steps {
        sh 'tflint --config="$WORKSPACE/.tflint.hcl" --init'
        sh 'tflint --config="$WORKSPACE/.tflint.hcl" --recursive --minimum-failure-severity=error'
      }
    }

    stage('Security Scan (tfsec)') {
      steps {
        // Non-zero exit when any HIGH/CRITICAL finding exists -> build fails.
        // Checkov alternative: checkov -d "$TF_DIR" --hard-fail-on HIGH
        sh 'tfsec "$TF_DIR" --minimum-severity HIGH --no-color'
      }
    }

    stage('Plan') {
      steps {
        script {
          def destroyFlag = params.ACTION == 'destroy' ? '-destroy' : ''
          tf "plan -input=false -lock-timeout=120s ${destroyFlag} -var-file=${params.ENVIRONMENT}.tfvars -out=tfplan"
          sh "terraform -chdir=${env.TF_DIR} show -no-color tfplan > ${env.TF_DIR}/tfplan.txt"
        }
        archiveArtifacts artifacts: "${env.TF_DIR}/tfplan, ${env.TF_DIR}/tfplan.txt", fingerprint: true
      }
    }

    stage('Cost Estimate (optional)') {
      when { expression { params.RUN_INFRACOST } }
      steps {
        withCredentials([string(credentialsId: 'infracost-api-key', variable: 'INFRACOST_API_KEY')]) {
          sh 'infracost breakdown --path "$TF_DIR" --terraform-var-file "$ENVIRONMENT.tfvars"'
        }
      }
    }

    stage('Approval') {
      when {
        beforeInput true
        allOf {
          branch 'main'
          expression { params.ACTION != 'plan' }
          expression { params.ENVIRONMENT == 'prod' || params.ACTION == 'destroy' }
        }
      }
      options { timeout(time: 30, unit: 'MINUTES') }
      input {
        message 'Review the archived plan. Proceed?'
        ok 'Approve'
      }
      steps {
        echo 'Approved - continuing.'
      }
    }

    stage('Apply') {
      when {
        allOf {
          branch 'main'
          expression { params.ACTION != 'plan' }
        }
      }
      steps {
        tf 'apply -input=false -lock-timeout=120s tfplan'
      }
    }
  }

  post {
    always {
      echo "Finished: ${currentBuild.currentResult}"
      deleteDir()
    }
    success {
      script { notify('SUCCESS') }
    }
    failure {
      script { notify('FAILURE') }
    }
  }
}
