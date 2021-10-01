deviceTypesCommon = require '@resin.io/device-types/common'
{ networkOptions, commonImg, instructions } = deviceTypesCommon

module.exports =
	version: 1
	slug: 'beaglebone-black'
	aliases: [ 'qsmp1570-qsbase1' ]
	name: 'QSMP-1570-QSBASE1'
	arch: 'armv7hf'
	state: 'experimental'

	instructions: commonImg.instructions
	gettingStartedLink:
		windows: ''
		osx: ''
		linux: ''
	supportsBlink: true

	options: [ networkOptions.group ]

	yocto:
		machine: 'qsmp1570-qsbase1'
		image: 'balena-image'
		fstype: 'balenaos-img'
		version: 'yocto-dunfell'
		deployArtifact: 'balena-image-qsmp1570-qsbase1.balenaos-img'
		compressed: true

	configuration:
		config:
			partition:
				primary: 1
			path: '/config.json'

	initialization: commonImg.initialization
