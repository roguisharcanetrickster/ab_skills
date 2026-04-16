SET FOREIGN_KEY_CHECKS = 0;
-- update the username 'admin' to have a6065ba6-a3a3-4cff-81cb-83b6f3e5887e as the uuid
UPDATE `SITE_USER`
SET uuid = 'a6065ba6-a3a3-4cff-81cb-83b6f3e5887e'
WHERE username = 'admin';

INSERT IGNORE INTO `site_tenant` (uuid,`key`,properties) VALUES
	 ('admin','admin','{ "title":"Tenant Admin", "authType":"login", "url":"https://[tenantKey].site.url" }');

LOCK TABLES `AB_JOINMN_ROLE_USER_users` WRITE;
INSERT IGNORE INTO `AB_JOINMN_ROLE_USER_users` (`created_at`, `updated_at`, `id`, `USER`, `ROLE`)
VALUES (
		NOW(),
		NOW(),
		"6",
		"admin",
		"e32dbd38-2300-4aac-84a9-d2c704bd2a29"
	);
INSERT IGNORE INTO `AB_JOINMN_ROLE_USER_users` (`created_at`, `updated_at`, `id`, `USER`, `ROLE`)
VALUES (
		NOW(),
		NOW(),
		"5",
		"admin",
		"7771bdb9-616c-48dc-9574-f8d167f44022"
	);
INSERT IGNORE INTO `AB_JOINMN_ROLE_USER_users` (`created_at`, `updated_at`, `id`, `USER`, `ROLE`)
VALUES (
		NOW(),
		NOW(),
		"7",
		"adminson",
		"7771bdb9-616c-48dc-9574-f8d167f44022"
	);
INSERT IGNORE INTO `AB_JOINMN_ROLE_USER_users` (`created_at`, `updated_at`, `id`, `USER`, `ROLE`)
VALUES (
		NOW(),
		NOW(),
		"8",
		"adminson",
		"dd6c2d34-0982-48b7-bc44-2456474edbea"
	);
INSERT IGNORE INTO `AB_JOINMN_ROLE_USER_users` (`created_at`, `updated_at`, `id`, `USER`, `ROLE`)
VALUES (
		NOW(),
		NOW(),
		"9",
		"adminson",
		"e32dbd38-2300-4aac-84a9-d2c704bd2a29"
	);
INSERT IGNORE INTO `AB_JOINMN_ROLE_USER_users` (`created_at`, `updated_at`, `id`, `USER`, `ROLE`)
VALUES (
		NOW(),
		NOW(),
		"10",
		"adminson",
		"e1be4d22-1d00-4c34-b205-ef84b8334b19"
	);
UNLOCK TABLES;
UNLOCK TABLES;
LOCK TABLES `SITE_USER` WRITE;
INSERT IGNORE INTO `SITE_USER` (
		uuid,
		created_at,
		updated_at,
		properties,
		failedLogins,
		lastLogin,
		isActive,
		sendEmailNotifications,
		image_id,
		username,
		password,
		salt,
		email,
		languageCode
	)
VALUES (
		'9219803e-49e8-11ed-8573-02420a000005',
		NULL,
		NULL,
		NULL,
		0,
		NULL,
		1,
		1,
		NULL,
		'punk',
		'3cf3b28ec9f125687dc855e7343f65ac5bda4cc259cce1e38e5f823bce4e0ab7a93eea7bbfcb8f45ce2e37da687390f58ead119fbef38b93148d62f569f8362dfe07073849c386573992617c147453a8c297e0352edd5349010e0b1700f04fc4231e4c0b6592d43b3640ebc3685d4d95ee909bcc53c07a92305a31b1e47dcf21000d866e5d82269cd339fa0a84335e9991e9615f83200e1c58b3cf348850fcc6aac8c002aeee40b368b5afcd8c2cc7bfc0235fd7f64b1ee3fa95bd469c1c97002dd3b5ed7ab08d831bc264a2b78ef3ce9fb02b0f0181c9e249a89bd83678fd688004944571166428ace9fbd40399ba966a3a89ba298be1d519c7d76b747d4096c8effe18afb327cc0a40e66a6b71a9625aba327553e29869a1606a0b94785a24f3ca761a6ed55d9346d5a6a2d0ccd531fea0be72dc5f43893fb67f030a7491d1d9dcb853ecdbe0a71ac147962ab2823f98373613904615b7fb4a52965a0e77344c0bada002160ab523c12af4d8bf32fea643ddc14f125f8a6881e8e306a8260821201dbf11386a84259a82c7d9a3078c48ed25c68ddb331dc999ce92de03cca60f72283a2644d7446ac278b2e23620650d31151fbae47cf42b447a89adea6bc73b3bebe152198720d79780eca25dc53026d3bed8fcf16513dc13b51a6817ee19d9e10880f7af867a365315cc46bf0181aa8b4d180ea07d9946361adaba3cb409',
		'451f7c023bc8885b08353f1210c5c72de69519381966ff0c738f5291ec427405',
		'email@punk.com',
		'en'
	),
	(
		'060fa9f0-df67-42fe-bf52-34f7014beb65',
		NULL,
		NULL,
		NULL,
		0,
		NULL,
		1,
		1,
		NULL,
		'adminson',
		'd77290f5b89b5f46000f63ace41884e6cab4d4e9289162140a69b814ead332c441b6863d20a0732d0a50bad4e3b3482f698f0f34c2841609f4dabcd6c1b760fe3c7f14ea1bdcc357dc7a3ec406163c36135c4708d509fdbef1069af361c5063058265de472da2a50066b57ade077e71bf154de25c186b2bd94457493366b7a1e8fe48a465b27d11417f17bee68816a8b3cefcafd0c233340963c99da7af53686d766104b4a69e9b7f361752d77cb45d1c95dec8816a3c2caeead21c6d57a2a22ba8c95e2f01530a4f2a95ecbe6c5b811a56e31b815051dbfe60e772b08482811bfe8e8d74716a10e3fe1aa7f9393d4856d641efe76d3f18417fad718ffa2f0583b2701464460ee79815e20990a079198cb3978494315882b67eb63d52a895301d4fc76e9a3cf02510dceb665ac5a6d1418443383111caef26baa1e299e130014d3a6220074ea1caeca3cc0e9c1097a5027f39b299641efafa231b8a01567ae42d3cf4159f654e93b47d6a45ac0442dfe6430cc1b4ec7013ceef047f8030e5574877a05df72b10b3aee20f000a600298ba725990c1e355d9861f9119b5a8287f16cfd6483235b5536535de7e0d5a401d14695296e27731d362c451cf561c6580de8c053b56a56ddead34f7d77bf5e94ce8630e5a30fc7d3227849e6c132d3e9c9aae41297ee1c64336c4f48c9ee7bb46a5d95394066746ba8eb23c3952c6678a6',
		'a810826af7b0c815713e608ccdc6cf259f246b22759914fd015978130aaa76ca',
		'email@admin.com',
		'en'
	);
UNLOCK TABLES;
SET FOREIGN_KEY_CHECKS = 1;