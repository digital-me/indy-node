#!groovy

// Load Jenkins shared libraries for all Hypeledger Indy project

def libIndy =[
	remote: 'https://github.com/digital-me/indy-jenkins-lib.git',
	branch: 'draft-01',
	credentialsId: null,
]

try {
	echo 'Trying to load shared libraries...' 
	library identifier: "libIndy@${libIndy.branch}", retriever: modernSCM(
		[$class: 'GitSCMSource',
			remote: libIndy.remote,
			credentialsId: libIndy.credentialsId]
	)
	echo 'Shared library loaded'
} catch (error) {
	echo "Could not load shared libraries: ${error.message}"
    currentBuild.result = 'FAILURE'
    return
}

// Initialize configuration
def config = initConfig()
if (!config) {
	// Fail config is empty
    currentBuild.result = 'FAILURE'
    return
}

// Define custom name, closures and methods for this project
def name = 'indy-node'

def nodeTestUbuntu = {
    try {
        echo 'Ubuntu Test: Checkout csm'
        checkout scm

        echo 'Ubuntu Test: Build docker image'
        def testEnv = dockerHelpers.build(name)

        testEnv.inside('--network host') {
            echo 'Ubuntu Test: Install dependencies'
            testHelpers.install()

            echo 'Ubuntu Test: Test'
            testHelpers.testRunner([resFile: "test-result-node.${NODE_NAME}.txt", testDir: 'indy_node'])
            //testHelpers.testJUnit(resFile: "test-result-node.${NODE_NAME}.xml")
        }
    }
    finally {
        echo 'Ubuntu Test: Cleanup'
        step([$class: 'WsCleanup'])
    }
}

def clientTestUbuntu = {
    try {
        echo 'Ubuntu Test: Checkout csm'
        checkout scm

        echo 'Ubuntu Test: Build docker image'
        def testEnv = dockerHelpers.build(name)

        testEnv.inside('--network host') {
            echo 'Ubuntu Test: Install dependencies'
            testHelpers.install()

            echo 'Ubuntu Test: Test'
            testHelpers.testRunner([resFile: "test-result-client.${NODE_NAME}.txt", testDir: 'indy_client'])
            //testHelpers.testJUnit(resFile: "test-result-client.${NODE_NAME}.xml")
        }
    }
    finally {
        echo 'Ubuntu Test: Cleanup'
        step([$class: 'WsCleanup'])
    }
}

def commonTestUbuntu = {
    try {
        echo 'Ubuntu Test: Checkout csm'
        checkout scm

        echo 'Ubuntu Test: Build docker image'
        def testEnv = dockerHelpers.build(name)

        testEnv.inside {
            echo 'Ubuntu Test: Install dependencies'
            testHelpers.install()

            echo 'Ubuntu Test: Test'
            testHelpers.testJUnit([resFile: "test-result-common.${NODE_NAME}.xml", testDir: 'indy_common'])
        }
    }
    finally {
        echo 'Ubuntu Test: Cleanup'
        step([$class: 'WsCleanup'])
    }
}

def buildDebUbuntu = { repoName, releaseVersion, sourcePath ->
    def volumeName = "$name-deb-u1604"
    if (env.BRANCH_NAME != '' && env.BRANCH_NAME != 'master') {
        volumeName = "${volumeName}.${BRANCH_NAME}"
    }
    if (sh(script: "docker volume ls -q | grep -q '^$volumeName\$'", returnStatus: true) == 0) {
        sh "docker volume rm $volumeName"
    }
    dir('build-scripts/ubuntu-1604') {
        sh "./build-$name-docker.sh \"$sourcePath\" $releaseVersion $volumeName"
        sh "./build-3rd-parties-docker.sh $volumeName"
    }
    return "$volumeName"
}

def buildRpmCentos = { repoName, releaseVersion, sourcePath ->
    def volumeName = "$name-rpm-c7.3.1611"
    if (env.BRANCH_NAME != '' && env.BRANCH_NAME != 'master') {
        volumeName = "${volumeName}.${BRANCH_NAME}"
    }
    if (sh(script: "docker volume ls -q | grep -q '^$volumeName\$'", returnStatus: true) == 0) {
        sh "docker volume rm $volumeName"
    }
    dir('build-scripts/centos-7.3.1611') {
        sh "./build-$name-docker.sh \"$sourcePath\" $releaseVersion $volumeName"
        sh "./build-3rd-parties-docker.sh $volumeName"
    }
    return "$volumeName"
}

// PIPELINE
stageCompile(name)
stageTest(name, [ubuntu: [node: nodeTestUbuntu, client: clientTestUbuntu, common: commonTestUbuntu]])
stagePackage(name, [ubuntu: buildDebUbuntu, centos: buildRpmCentos])
stageRelease(name)
stageDelivery(name)
stageNotify(name)
