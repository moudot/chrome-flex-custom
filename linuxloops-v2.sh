#!/usr/bin/env bash

usage()
{
cat << USAGE
LinuxLoops: Adaptable / declarative linux distribution installer.
Usage: bash \${HOME}/bin/linuxloops -distro <distribution name> -ver <distribution version> -env <environment name> -dst <disk name or disk image path>
-distro, --distribution <distribution name>		(Distribution to install)
-ver, --version <version name>				(Distribution version to install)
-env, --environment <environment name>			(Environment to install)
-dst, --destination <disk name or disk image path>	(e.g. /dev/sda or /ubuntu.img)
-s, --size <total install size>				(number in GB, minimum 14GB)
-z, --swapsize <swap size>				(number in GB)
-b, --btrfs						(Use btrfs for the root filesystem)
-r, --rootfs-compression				(Enable standard btrfs compression, implies -b)
-e, --encrypt						(Encrypt the root filesystem)
-a, --autologin						(Enable user autologin)
    --efi-name						(EFI partition name)
    --efi-mountoptions					(EFI partition specific mountoptions)
    --boot-name						(Boot partition name)
    --boot-mountoptions					(Boot partition specific mountoptions)
    --root-name						(Root partition name)
    --root-mountoptions					(Root partition specific mountoptions)
-A, --add-partition <partition details>			(Add a partition according to the below format:
							<mountpoint>*<name>*<fstype>*<mountoptions>*<size(in GB)>*<encryption>
							ex: /home*Home*ext4*noatime,discard*20*Yes)
-H, --hostname						(Provide a specific hostname)
-L, --locale <locale>					(specify locale to be used, by default "en_US")
-K, --keymap <keymap>					(specify keymap to be used, by default "us")
-T, --timezone <timezone>				(specify timezone to be used, by default "UTC")
-n, --nvidia						(Install nvidia drivers)
-S, --surface						(Add patches for Surface devices from github.com/linux-surface)
-c, --custom-packages					(list of additional packages to be installed - space separated)
-C, --custom-script					(bash script that should be run at the end of the install process)
-k, --kernel-parameters					(specific kernel parameters to be applied - space separated)
-m, --custom-mirror <mirror details>			(Add a custom mirror according to the below format:
							<repository>*<mirror>
							ex: Arch*https://mirrors.kernel.org/archlinux)
-p, --user-password-for-encryption			(Use user account password for encryption)
-g, --grub-hide						(Hide the GRUB Bootloader)
-G, --generate-declarative-config <config_file_path>	(Generate a declarative configuration file)
-d, --apply-declarative-config <config_file_path>	(Use a declarative configuration file)
-l, --list						(List available distributions and environments)
-lb, --list-btrfs					(Confirms if btrfs is supported for chosen distribution/version)
-ld, --list-distributions				(List available distributions)
-le, --list-environments				(List available environments for chosen distribution/version)
-ll, --list-locales					(List available locales)
-lk, --list-keymaps					(List available keymaps)
-ln, --list-nvidia					(Confirms if nvidia proprietary driver is supported for chosen distribution/version)
-ls, --list-surface					(Confirms if Surface devices patches are supported for chosen distribution/version)
-lt, --list-timezones					(List available timezones)
-lv, --list-versions					(List available versions for chosen distribution)
-h, --help						(Display this menu)
-B, --bin-path					(fournir directement le chemin du .bin local)
USAGE
}

available_distributions=( "ChromeOS-Flex" )

distribution_parameters()
{
case "${distribution}" in

	'ChromeOS-Flex')
		available_versions=( "Stable" )
		available_versions_longname=( "${available_versions[@]}" )
		default_version="Stable"
		;;
	*)
		echo "Distribution ${distribution} is not supported."
		exit 1
		;;
esac
if [ -z "${version}" ]; then version="${default_version}"; fi
}

distribution_version_parameters()
{
chroot_function="${distribution}"
case "${distribution}" in

	'ChromeOS-Flex')
		available_environments=( "Standard" "Devmode" )
		bootloader_id="boot"
		bootloader_name="bootx64.efi"
		bootstrap="lxc archlinux current default"
		btrfs_supported="No"
		chromeos_flex_version="${version}"
		mirrors_supported=()
		nvidia_supported="No"
		surface_supported="No"
		;;
esac
}

available_locales=(
"TRUE" "en_US" "American English, United States"
"FALSE" "aa_DJ" "Afar, Djibouti"
"FALSE" "aa_ER" "Afar, Eritrea"
"FALSE" "aa_ET" "Afar, Ethiopia"
"FALSE" "ab_GE" "Abkhazian, Georgia"
"FALSE" "af_ZA" "Afrikaans, South Africa"
"FALSE" "agr_PE" "Aguaruna, Peru"
"FALSE" "ak_GH" "Akan, Ghana"
"FALSE" "am_ET" "Amharic, Ethiopia"
"FALSE" "an_ES" "Aragonese, Spain"
"FALSE" "anp_IN" "Angika, India"
"FALSE" "ar_AE" "Arabic, United Arab Emirates"
"FALSE" "ar_BH" "Arabic, Bahrain"
"FALSE" "ar_DZ" "Arabic, Algeria"
"FALSE" "ar_EG" "Arabic, Egypt"
"FALSE" "ar_IN" "Arabic, India"
"FALSE" "ar_IQ" "Arabic, Iraq"
"FALSE" "ar_JO" "Arabic, Jordan"
"FALSE" "ar_KW" "Arabic, Kuwait"
"FALSE" "ar_LB" "Arabic, Lebanon"
"FALSE" "ar_LY" "Arabic, Libya"
"FALSE" "ar_MA" "Arabic, Morocco"
"FALSE" "ar_OM" "Arabic, Oman"
"FALSE" "ar_QA" "Arabic, Qatar"
"FALSE" "ar_SA" "Arabic, Saudi Arabia"
"FALSE" "ar_SD" "Arabic, Sudan"
"FALSE" "ar_SS" "Arabic, South Sudan"
"FALSE" "ar_SY" "Arabic, Syria"
"FALSE" "ar_TN" "Arabic, Tunisia"
"FALSE" "ar_YE" "Arabic, Yemen"
"FALSE" "as_IN" "Assamese, India"
"FALSE" "ast_ES" "Asturian, Spain"
"FALSE" "ayc_PE" "Aymara, Peru"
"FALSE" "az_AZ" "Azerbaijani, Azerbaijan"
"FALSE" "az_IR" "South Azerbaijani, Iran"
"FALSE" "be_BY" "Belarusian, Belarus"
"FALSE" "bem_ZM" "Bemba, Zambia"
"FALSE" "ber_DZ" "Berber, Algeria"
"FALSE" "ber_MA" "Berber, Morocco"
"FALSE" "bg_BG" "Bulgarian, Bulgaria"
"FALSE" "bhb_IN" "Bhili, India"
"FALSE" "bho_IN" "Bhojpuri, India"
"FALSE" "bho_NP" "Bhojpuri, Nepal"
"FALSE" "bi_VU" "Bislama, Vanuatu"
"FALSE" "bn_BD" "Bangla, Bangladesh"
"FALSE" "bn_IN" "Bangla, India"
"FALSE" "bo_CN" "Tibetan, China"
"FALSE" "bo_IN" "Tibetan, India"
"FALSE" "br_FR" "Breton, France"
"FALSE" "brx_IN" "Bodo, India"
"FALSE" "bs_BA" "Bosnian, Bosnia & Herzegovina"
"FALSE" "byn_ER" "Blin, Eritrea"
"FALSE" "ca_AD" "Catalan, Andorra"
"FALSE" "ca_ES" "Catalan, Spain"
"FALSE" "ca_FR" "Catalan, France"
"FALSE" "ca_IT" "Catalan, Italy"
"FALSE" "ce_RU" "Chechen, Russia"
"FALSE" "chr_US" "Cherokee, United States"
"FALSE" "ckb_IQ" "Central Kurdish, Iraq"
"FALSE" "cmn_TW" "Mandarin Chinese, Taiwan"
"FALSE" "crh_UA" "Crimean Tatar, Ukraine"
"FALSE" "csb_PL" "Kashubian, Poland"
"FALSE" "cs_CZ" "Czech, Czech Republic"
"FALSE" "cv_RU" "Chuvash, Russia"
"FALSE" "cy_GB" "Welsh, United Kingdom"
"FALSE" "da_DK" "Danish, Denmark"
"FALSE" "de_AT" "Austrian German, Austria"
"FALSE" "de_BE" "German, Belgium"
"FALSE" "de_CH" "Swiss High German, Switzerland"
"FALSE" "de_DE" "German, Germany"
"FALSE" "de_IT" "German, Italy"
"FALSE" "de_LI" "German, Liechtenstein"
"FALSE" "de_LU" "German, Luxembourg"
"FALSE" "doi_IN" "Dogri, India"
"FALSE" "dsb_DE" "Lower Sorbian, Germany"
"FALSE" "dv_MV" "Divehi, Maldives"
"FALSE" "dz_BT" "Dzongkha, Bhutan"
"FALSE" "el_CY" "Greek, Cyprus"
"FALSE" "el_GR" "Greek, Greece"
"FALSE" "en_AG" "English, Antigua & Barbuda"
"FALSE" "en_AU" "Australian English, Australia"
"FALSE" "en_BW" "English, Botswana"
"FALSE" "en_CA" "Canadian English, Canada"
"FALSE" "en_DK" "English, Denmark"
"FALSE" "en_GB" "British English, United Kingdom"
"FALSE" "en_HK" "English, Hong Kong SAR China"
"FALSE" "en_IE" "English, Ireland"
"FALSE" "en_IL" "English, Israel"
"FALSE" "en_IN" "English, India"
"FALSE" "en_NG" "English, Nigeria"
"FALSE" "en_NZ" "English, New Zealand"
"FALSE" "en_PH" "English, Philippines"
"FALSE" "en_SC" "English, Seychelles"
"FALSE" "en_SG" "English, Singapore"
"FALSE" "en_ZA" "English, South Africa"
"FALSE" "en_ZM" "English, Zambia"
"FALSE" "en_ZW" "English, Zimbabwe"
"FALSE" "es_AR" "Spanish, Argentina"
"FALSE" "es_BO" "Spanish, Bolivia"
"FALSE" "es_CL" "Spanish, Chile"
"FALSE" "es_CO" "Spanish, Colombia"
"FALSE" "es_CR" "Spanish, Costa Rica"
"FALSE" "es_CU" "Spanish, Cuba"
"FALSE" "es_DO" "Spanish, Dominican Republic"
"FALSE" "es_EC" "Spanish, Ecuador"
"FALSE" "es_ES" "European Spanish, Spain"
"FALSE" "es_GT" "Spanish, Guatemala"
"FALSE" "es_HN" "Spanish, Honduras"
"FALSE" "es_MX" "Mexican Spanish, Mexico"
"FALSE" "es_NI" "Spanish, Nicaragua"
"FALSE" "es_PA" "Spanish, Panama"
"FALSE" "es_PE" "Spanish, Peru"
"FALSE" "es_PR" "Spanish, Puerto Rico"
"FALSE" "es_PY" "Spanish, Paraguay"
"FALSE" "es_SV" "Spanish, El Salvador"
"FALSE" "es_UY" "Spanish, Uruguay"
"FALSE" "es_VE" "Spanish, Venezuela"
"FALSE" "et_EE" "Estonian, Estonia"
"FALSE" "eu_ES" "Basque, Spain"
"FALSE" "fa_IR" "Persian, Iran"
"FALSE" "ff_SN" "Fulah, Senegal"
"FALSE" "fi_FI" "Finnish, Finland"
"FALSE" "fil_PH" "Filipino, Philippines"
"FALSE" "fo_FO" "Faroese, Faroe Islands"
"FALSE" "fr_BE" "French, Belgium"
"FALSE" "fr_CA" "Canadian French, Canada"
"FALSE" "fr_CH" "Swiss French, Switzerland"
"FALSE" "fr_FR" "French, France"
"FALSE" "fr_LU" "French, Luxembourg"
"FALSE" "fur_IT" "Friulian, Italy"
"FALSE" "fy_DE" "Western Frisian, Germany"
"FALSE" "fy_NL" "Western Frisian, Netherlands"
"FALSE" "ga_IE" "Irish, Ireland"
"FALSE" "gd_GB" "Scottish Gaelic, United Kingdom"
"FALSE" "gez_ER" "Geez, Eritrea"
"FALSE" "gez_ET" "Geez, Ethiopia"
"FALSE" "gl_ES" "Galician, Spain"
"FALSE" "gu_IN" "Gujarati, India"
"FALSE" "gv_GB" "Manx, United Kingdom"
"FALSE" "hak_TW" "Hakka Chinese, Taiwan"
"FALSE" "ha_NG" "Hausa, Nigeria"
"FALSE" "he_IL" "Hebrew, Israel"
"FALSE" "hif_FJ" "Fiji Hindi, Fiji"
"FALSE" "hi_IN" "Hindi, India"
"FALSE" "hne_IN" "Chhattisgarhi, India"
"FALSE" "hr_HR" "Croatian, Croatia"
"FALSE" "hsb_DE" "Upper Sorbian, Germany"
"FALSE" "ht_HT" "Haitian Creole, Haiti"
"FALSE" "hu_HU" "Hungarian, Hungary"
"FALSE" "hy_AM" "Armenian, Armenia"
"FALSE" "ia_FR" "Interlingua, France"
"FALSE" "id_ID" "Indonesian, Indonesia"
"FALSE" "ig_NG" "Igbo, Nigeria"
"FALSE" "ik_CA" "Inupiaq, Canada"
"FALSE" "is_IS" "Icelandic, Iceland"
"FALSE" "it_CH" "Italian, Switzerland"
"FALSE" "it_IT" "Italian, Italy"
"FALSE" "iu_CA" "Inuktitut, Canada"
"FALSE" "ja_JP" "Japanese, Japan"
"FALSE" "kab_DZ" "Kabyle, Algeria"
"FALSE" "ka_GE" "Georgian, Georgia"
"FALSE" "kk_KZ" "Kazakh, Kazakhstan"
"FALSE" "kl_GL" "Kalaallisut, Greenland"
"FALSE" "km_KH" "Khmer, Cambodia"
"FALSE" "kn_IN" "Kannada, India"
"FALSE" "kok_IN" "Konkani, India"
"FALSE" "ko_KR" "Korean, South Korea"
"FALSE" "ks_IN" "Kashmiri, India"
"FALSE" "ku_TR" "Kurdish, Turkey"
"FALSE" "kw_GB" "Cornish, United Kingdom"
"FALSE" "ky_KG" "Kyrgyz, Kyrgyzstan"
"FALSE" "lb_LU" "Luxembourgish, Luxembourg"
"FALSE" "lg_UG" "Ganda, Uganda"
"FALSE" "li_BE" "Limburgish, Belgium"
"FALSE" "lij_IT" "Ligurian, Italy"
"FALSE" "li_NL" "Limburgish, Netherlands"
"FALSE" "ln_CD" "Lingala, Democratic Republic of the Congo"
"FALSE" "lo_LA" "Lao, Laos"
"FALSE" "lt_LT" "Lithuanian, Lithuania"
"FALSE" "lv_LV" "Latvian, Latvia"
"FALSE" "lzh_TW" "Literary Chinese, Taiwan"
"FALSE" "mag_IN" "Magahi, India"
"FALSE" "mai_IN" "Maithili, India"
"FALSE" "mai_NP" "Maithili, Nepal"
"FALSE" "mfe_MU" "Morisyen, Mauritius"
"FALSE" "mg_MG" "Malagasy, Madagascar"
"FALSE" "mhr_RU" "Meadow Mari, Russia"
"FALSE" "mi_NZ" "Maori, New Zealand"
"FALSE" "miq_NI" "Miskito, Nicaragua"
"FALSE" "mjw_IN" "Karbi, India"
"FALSE" "mk_MK" "Macedonian, Macedonia"
"FALSE" "ml_IN" "Malayalam, India"
"FALSE" "mni_IN" "Manipuri, India"
"FALSE" "mn_MN" "Mongolian, Mongolia"
"FALSE" "mnw_MM" "Mon, Myanmar"
"FALSE" "mr_IN" "Marathi, India"
"FALSE" "ms_MY" "Malay, Malaysia"
"FALSE" "mt_MT" "Maltese, malta"
"FALSE" "my_MM" "Burmese, Myanmar (Burma)"
"FALSE" "nan_TW" "Min Nan Chinese, Taiwan"
"FALSE" "nb_NO" "Norwegian Bokm<U00E5>l, Norway"
"FALSE" "nds_DE" "Low German, Germany"
"FALSE" "nds_NL" "Low Saxon, Netherlands"
"FALSE" "ne_NP" "Nepali, Nepal"
"FALSE" "nhn_MX" "Central Nahuatl, Mexico"
"FALSE" "niu_NU" "Niuean, Niue"
"FALSE" "niu_NZ" "Niuean, New Zealand"
"FALSE" "nl_AW" "Dutch, Aruba"
"FALSE" "nl_BE" "Flemish, Belgium"
"FALSE" "nl_NL" "Dutch, Netherlands"
"FALSE" "nn_NO" "Norwegian Nynorsk, Norway"
"FALSE" "nr_ZA" "South Ndebele, South Africa"
"FALSE" "nso_ZA" "Northern Sotho, South Africa"
"FALSE" "oc_FR" "Occitan, France"
"FALSE" "om_ET" "Oromo, Ethiopia"
"FALSE" "om_KE" "Oromo, Kenya"
"FALSE" "or_IN" "Odia, India"
"FALSE" "os_RU" "Ossetic, Russia"
"FALSE" "pa_IN" "Punjabi, India"
"FALSE" "pap_AW" "Papiamento, Aruba"
"FALSE" "pap_CW" "Papiamento, Cura<U00E7>ao"
"FALSE" "pa_PK" "Punjabi, Pakistan"
"FALSE" "pl_PL" "Polish, Poland"
"FALSE" "ps_AF" "Pashto, Afghanistan"
"FALSE" "pt_BR" "Brazilian Portuguese, Brazil"
"FALSE" "pt_PT" "European Portuguese, Portugal"
"FALSE" "quz_PE" "Cusco Quechua, Peru"
"FALSE" "raj_IN" "Rajasthani, India"
"FALSE" "rif_MA" "Tarifit, Morocco"
"FALSE" "ro_RO" "Romanian, Romania"
"FALSE" "ru_RU" "Russian, Russia"
"FALSE" "ru_UA" "Russian, Ukraine"
"FALSE" "rw_RW" "Kinyarwanda, Rwanda"
"FALSE" "sah_RU" "Sakha, Russian Federation"
"FALSE" "sa_IN" "Sanskrit, India"
"FALSE" "sat_IN" "Santali, India"
"FALSE" "sc_IT" "Sardinian, Italy"
"FALSE" "sd_IN" "Sindhi, India"
"FALSE" "se_NO" "Northern Sami, Norway"
"FALSE" "sgs_LT" "Samogitian, Lithuania"
"FALSE" "shn_MM" "Shan, Myanmar"
"FALSE" "shs_CA" "Shuswap, Canada"
"FALSE" "sid_ET" "Sidamo, Ethiopia"
"FALSE" "si_LK" "Sinhala, Sri Lanka"
"FALSE" "sk_SK" "Slovak, Slovakia"
"FALSE" "sl_SI" "Slovenian, Slovenia"
"FALSE" "sm_WS" "Samoan, Samoa"
"FALSE" "so_DJ" "Somali, Djibouti"
"FALSE" "so_ET" "Somali, Ethiopia"
"FALSE" "so_KE" "Somali, Kenya"
"FALSE" "so_SO" "Somali, Somalia"
"FALSE" "sq_AL" "Albanian, Albania"
"FALSE" "sq_MK" "Albanian, Macedonia"
"FALSE" "sr_ME" "Serbian, Montenegro"
"FALSE" "sr_RS" "Serbian, Serbia"
"FALSE" "ss_ZA" "Swati, South Africa"
"FALSE" "st_ZA" "Southern Sotho, South Africa"
"FALSE" "sv_FI" "Swedish, Finland"
"FALSE" "sv_SE" "Swedish, Sweden"
"FALSE" "sw_KE" "Swahili, Kenya"
"FALSE" "sw_TZ" "Swahili, Tanzania"
"FALSE" "szl_PL" "Silesian, Poland"
"FALSE" "ta_IN" "Tamil, India"
"FALSE" "ta_LK" "Tamil, Sri Lanka"
"FALSE" "tcy_IN" "Tulu, India"
"FALSE" "te_IN" "Telugu, India"
"FALSE" "tg_TJ" "Tajik, Tajikistan"
"FALSE" "the_NP" "Chitwania Tharu, Nepal"
"FALSE" "th_TH" "Thai, Thailand"
"FALSE" "ti_ER" "Tigrinya, Eritrea"
"FALSE" "ti_ET" "Tigrinya, Ethiopia"
"FALSE" "tig_ER" "Tigre, Eritrea"
"FALSE" "tk_TM" "Turkmen, Turkmenistan"
"FALSE" "tl_PH" "Tagalog, Philippines"
"FALSE" "tn_ZA" "Tswana, South Africa"
"FALSE" "to_TO" "Tongan, Tonga"
"FALSE" "tpi_PG" "Tok Pisin, Papua New Guinea"
"FALSE" "tr_CY" "Turkish, Cyprus"
"FALSE" "tr_TR" "Turkish, Turkey"
"FALSE" "ts_ZA" "Tsonga, South Africa"
"FALSE" "tt_RU" "Tatar, Russia"
"FALSE" "ug_CN" "Uyghur, China"
"FALSE" "uk_UA" "Ukrainian, Ukraine"
"FALSE" "unm_US" "Unami Delaware, United States"
"FALSE" "ur_IN" "Urdu, India"
"FALSE" "ur_PK" "Urdu, Pakistan"
"FALSE" "uz_UZ" "Uzbek, Uzbekistan"
"FALSE" "ve_ZA" "Venda, South Africa"
"FALSE" "vi_VN" "Vietnamese, Vietnam"
"FALSE" "wa_BE" "Walloon, Belgium"
"FALSE" "wae_CH" "Walser, Switzerland"
"FALSE" "wal_ET" "Wolaytta, Ethiopia"
"FALSE" "wo_SN" "Wolof, Senegal"
"FALSE" "xh_ZA" "Xhosa, South Africa"
"FALSE" "yi_US" "Yiddish, United States"
"FALSE" "yo_NG" "Yoruba, Nigeria"
"FALSE" "yue_HK" "Cantonese, Hong Kong SAR China"
"FALSE" "yuw_PG" "Yau, Papua New Guinea"
"FALSE" "zh_CN" "Chinese, China"
"FALSE" "zh_HK" "Chinese, Hong Kong SAR China"
"FALSE" "zh_SG" "Chinese, Singapore"
"FALSE" "zh_TW" "Chinese, Taiwan"
"FALSE" "zu_ZA" "Zulu, South Africa"
"FALSE" "C" "Default locale"
)

available_keymaps=(
"TRUE" "us" "USA"
"FALSE" "ad" "Andorra"
"FALSE" "af" "Afghanistan"
"FALSE" "al" "Albania"
"FALSE" "am" "Armenia"
"FALSE" "ara" "Arabic"
"FALSE" "az" "Azerbaijan"
"FALSE" "ba" "Bosnia and Herzegovina"
"FALSE" "bd" "Bangladesh"
"FALSE" "be" "Belgium"
"FALSE" "bg" "Bulgaria"
"FALSE" "br" "Brazil"
"FALSE" "brai" "Braille"
"FALSE" "bt" "Bhutan"
"FALSE" "by" "Belarus"
"FALSE" "ca" "Canada"
"FALSE" "cd" "Congo, Democratic Republic of the"
"FALSE" "ch" "Switzerland"
"FALSE" "cn" "China"
"FALSE" "cz" "Czechia"
"FALSE" "de" "Germany"
"FALSE" "dk" "Denmark"
"FALSE" "ee" "Estonia"
"FALSE" "es" "Spain"
"FALSE" "et" "Ethiopia"
"FALSE" "fi" "Finland"
"FALSE" "fo" "Faroe Islands"
"FALSE" "fr" "France"
"FALSE" "gb" "United Kingdom"
"FALSE" "ge" "Georgia"
"FALSE" "gh" "Ghana"
"FALSE" "gn" "Guinea"
"FALSE" "gr" "Greece"
"FALSE" "hr" "Croatia"
"FALSE" "hu" "Hungary"
"FALSE" "ie" "Ireland"
"FALSE" "il" "Israel"
"FALSE" "in" "India"
"FALSE" "iq" "Iraq"
"FALSE" "ir" "Iran"
"FALSE" "is" "Iceland"
"FALSE" "it" "Italy"
"FALSE" "jp" "Japan"
"FALSE" "kg" "Kyrgyzstan"
"FALSE" "kh" "Cambodia"
"FALSE" "kr" "Korea, Republic of"
"FALSE" "kz" "Kazakhstan"
"FALSE" "la" "Laos"
"FALSE" "latam" "Latin American"
"FALSE" "lk" "Sri Lanka"
"FALSE" "lt" "Lithuania"
"FALSE" "lv" "Latvia"
"FALSE" "ma" "Morocco"
"FALSE" "mao" "Maori"
"FALSE" "me" "Montenegro"
"FALSE" "mk" "Macedonia"
"FALSE" "ml" "Mali"
"FALSE" "mm" "Myanmar"
"FALSE" "mn" "Mongolia"
"FALSE" "mt" "Malta"
"FALSE" "mv" "Maldives"
"FALSE" "ng" "Nigeria"
"FALSE" "nl" "Netherlands"
"FALSE" "no" "Norway"
"FALSE" "np" "Nepal"
"FALSE" "pk" "Pakistan"
"FALSE" "pl" "Poland"
"FALSE" "pt" "Portugal"
"FALSE" "ro" "Romania"
"FALSE" "rs" "Serbia"
"FALSE" "ru" "Russia"
"FALSE" "se" "Sweden"
"FALSE" "si" "Slovenia"
"FALSE" "sk" "Slovakia"
"FALSE" "sn" "Senegal"
"FALSE" "sy" "Syria"
"FALSE" "th" "Thailand"
"FALSE" "tj" "Tajikistan"
"FALSE" "tm" "Turkmenistan"
"FALSE" "tr" "Turkey"
"FALSE" "tw" "Taiwan"
"FALSE" "tz" "Tanzania"
"FALSE" "ua" "Ukraine"
"FALSE" "uz" "Uzbekistan"
"FALSE" "vn" "Vietnam"
"FALSE" "za" "South Africa"
)

available_timezones=(
"TRUE" "UTC"
"FALSE" "Africa/Abidjan"
"FALSE" "Africa/Accra"
"FALSE" "Africa/Addis_Ababa"
"FALSE" "Africa/Algiers"
"FALSE" "Africa/Asmara"
"FALSE" "Africa/Asmera"
"FALSE" "Africa/Bamako"
"FALSE" "Africa/Bangui"
"FALSE" "Africa/Banjul"
"FALSE" "Africa/Bissau"
"FALSE" "Africa/Blantyre"
"FALSE" "Africa/Brazzaville"
"FALSE" "Africa/Bujumbura"
"FALSE" "Africa/Cairo"
"FALSE" "Africa/Casablanca"
"FALSE" "Africa/Ceuta"
"FALSE" "Africa/Conakry"
"FALSE" "Africa/Dakar"
"FALSE" "Africa/Dar_es_Salaam"
"FALSE" "Africa/Djibouti"
"FALSE" "Africa/Douala"
"FALSE" "Africa/El_Aaiun"
"FALSE" "Africa/Freetown"
"FALSE" "Africa/Gaborone"
"FALSE" "Africa/Harare"
"FALSE" "Africa/Johannesburg"
"FALSE" "Africa/Juba"
"FALSE" "Africa/Kampala"
"FALSE" "Africa/Khartoum"
"FALSE" "Africa/Kigali"
"FALSE" "Africa/Kinshasa"
"FALSE" "Africa/Lagos"
"FALSE" "Africa/Libreville"
"FALSE" "Africa/Lome"
"FALSE" "Africa/Luanda"
"FALSE" "Africa/Lubumbashi"
"FALSE" "Africa/Lusaka"
"FALSE" "Africa/Malabo"
"FALSE" "Africa/Maputo"
"FALSE" "Africa/Maseru"
"FALSE" "Africa/Mbabane"
"FALSE" "Africa/Mogadishu"
"FALSE" "Africa/Monrovia"
"FALSE" "Africa/Nairobi"
"FALSE" "Africa/Ndjamena"
"FALSE" "Africa/Niamey"
"FALSE" "Africa/Nouakchott"
"FALSE" "Africa/Ouagadougou"
"FALSE" "Africa/Porto-Novo"
"FALSE" "Africa/Sao_Tome"
"FALSE" "Africa/Timbuktu"
"FALSE" "Africa/Tripoli"
"FALSE" "Africa/Tunis"
"FALSE" "Africa/Windhoek"
"FALSE" "America/Adak"
"FALSE" "America/Anchorage"
"FALSE" "America/Anguilla"
"FALSE" "America/Antigua"
"FALSE" "America/Araguaina"
"FALSE" "America/Argentina/Buenos_Aires"
"FALSE" "America/Argentina/Catamarca"
"FALSE" "America/Argentina/ComodRivadavia"
"FALSE" "America/Argentina/Cordoba"
"FALSE" "America/Argentina/Jujuy"
"FALSE" "America/Argentina/La_Rioja"
"FALSE" "America/Argentina/Mendoza"
"FALSE" "America/Argentina/Rio_Gallegos"
"FALSE" "America/Argentina/Salta"
"FALSE" "America/Argentina/San_Juan"
"FALSE" "America/Argentina/San_Luis"
"FALSE" "America/Argentina/Tucuman"
"FALSE" "America/Argentina/Ushuaia"
"FALSE" "America/Aruba"
"FALSE" "America/Asuncion"
"FALSE" "America/Atikokan"
"FALSE" "America/Atka"
"FALSE" "America/Bahia"
"FALSE" "America/Bahia_Banderas"
"FALSE" "America/Barbados"
"FALSE" "America/Belem"
"FALSE" "America/Belize"
"FALSE" "America/Blanc-Sablon"
"FALSE" "America/Boa_Vista"
"FALSE" "America/Bogota"
"FALSE" "America/Boise"
"FALSE" "America/Buenos_Aires"
"FALSE" "America/Cambridge_Bay"
"FALSE" "America/Campo_Grande"
"FALSE" "America/Cancun"
"FALSE" "America/Caracas"
"FALSE" "America/Catamarca"
"FALSE" "America/Cayenne"
"FALSE" "America/Cayman"
"FALSE" "America/Chicago"
"FALSE" "America/Chihuahua"
"FALSE" "America/Ciudad_Juarez"
"FALSE" "America/Coral_Harbour"
"FALSE" "America/Cordoba"
"FALSE" "America/Costa_Rica"
"FALSE" "America/Creston"
"FALSE" "America/Cuiaba"
"FALSE" "America/Curacao"
"FALSE" "America/Danmarkshavn"
"FALSE" "America/Dawson"
"FALSE" "America/Dawson_Creek"
"FALSE" "America/Denver"
"FALSE" "America/Detroit"
"FALSE" "America/Dominica"
"FALSE" "America/Edmonton"
"FALSE" "America/Eirunepe"
"FALSE" "America/El_Salvador"
"FALSE" "America/Ensenada"
"FALSE" "America/Fort_Nelson"
"FALSE" "America/Fort_Wayne"
"FALSE" "America/Fortaleza"
"FALSE" "America/Glace_Bay"
"FALSE" "America/Godthab"
"FALSE" "America/Goose_Bay"
"FALSE" "America/Grand_Turk"
"FALSE" "America/Grenada"
"FALSE" "America/Guadeloupe"
"FALSE" "America/Guatemala"
"FALSE" "America/Guayaquil"
"FALSE" "America/Guyana"
"FALSE" "America/Halifax"
"FALSE" "America/Havana"
"FALSE" "America/Hermosillo"
"FALSE" "America/Indiana/Indianapolis"
"FALSE" "America/Indiana/Knox"
"FALSE" "America/Indiana/Marengo"
"FALSE" "America/Indiana/Petersburg"
"FALSE" "America/Indiana/Tell_City"
"FALSE" "America/Indiana/Vevay"
"FALSE" "America/Indiana/Vincennes"
"FALSE" "America/Indiana/Winamac"
"FALSE" "America/Indianapolis"
"FALSE" "America/Inuvik"
"FALSE" "America/Iqaluit"
"FALSE" "America/Jamaica"
"FALSE" "America/Jujuy"
"FALSE" "America/Juneau"
"FALSE" "America/Kentucky/Louisville"
"FALSE" "America/Kentucky/Monticello"
"FALSE" "America/Knox_IN"
"FALSE" "America/Kralendijk"
"FALSE" "America/La_Paz"
"FALSE" "America/Lima"
"FALSE" "America/Los_Angeles"
"FALSE" "America/Louisville"
"FALSE" "America/Lower_Princes"
"FALSE" "America/Maceio"
"FALSE" "America/Managua"
"FALSE" "America/Manaus"
"FALSE" "America/Marigot"
"FALSE" "America/Martinique"
"FALSE" "America/Matamoros"
"FALSE" "America/Mazatlan"
"FALSE" "America/Mendoza"
"FALSE" "America/Menominee"
"FALSE" "America/Merida"
"FALSE" "America/Metlakatla"
"FALSE" "America/Mexico_City"
"FALSE" "America/Miquelon"
"FALSE" "America/Moncton"
"FALSE" "America/Monterrey"
"FALSE" "America/Montevideo"
"FALSE" "America/Montreal"
"FALSE" "America/Montserrat"
"FALSE" "America/Nassau"
"FALSE" "America/New_York"
"FALSE" "America/Nipigon"
"FALSE" "America/Nome"
"FALSE" "America/Noronha"
"FALSE" "America/North_Dakota/Beulah"
"FALSE" "America/North_Dakota/Center"
"FALSE" "America/North_Dakota/New_Salem"
"FALSE" "America/Nuuk"
"FALSE" "America/Ojinaga"
"FALSE" "America/Panama"
"FALSE" "America/Pangnirtung"
"FALSE" "America/Paramaribo"
"FALSE" "America/Phoenix"
"FALSE" "America/Port-au-Prince"
"FALSE" "America/Port_of_Spain"
"FALSE" "America/Porto_Acre"
"FALSE" "America/Porto_Velho"
"FALSE" "America/Puerto_Rico"
"FALSE" "America/Punta_Arenas"
"FALSE" "America/Rainy_River"
"FALSE" "America/Rankin_Inlet"
"FALSE" "America/Recife"
"FALSE" "America/Regina"
"FALSE" "America/Resolute"
"FALSE" "America/Rio_Branco"
"FALSE" "America/Rosario"
"FALSE" "America/Santa_Isabel"
"FALSE" "America/Santarem"
"FALSE" "America/Santiago"
"FALSE" "America/Santo_Domingo"
"FALSE" "America/Sao_Paulo"
"FALSE" "America/Scoresbysund"
"FALSE" "America/Shiprock"
"FALSE" "America/Sitka"
"FALSE" "America/St_Barthelemy"
"FALSE" "America/St_Johns"
"FALSE" "America/St_Kitts"
"FALSE" "America/St_Lucia"
"FALSE" "America/St_Thomas"
"FALSE" "America/St_Vincent"
"FALSE" "America/Swift_Current"
"FALSE" "America/Tegucigalpa"
"FALSE" "America/Thule"
"FALSE" "America/Thunder_Bay"
"FALSE" "America/Tijuana"
"FALSE" "America/Toronto"
"FALSE" "America/Tortola"
"FALSE" "America/Vancouver"
"FALSE" "America/Virgin"
"FALSE" "America/Whitehorse"
"FALSE" "America/Winnipeg"
"FALSE" "America/Yakutat"
"FALSE" "America/Yellowknife"
"FALSE" "Antarctica/Casey"
"FALSE" "Antarctica/Davis"
"FALSE" "Antarctica/DumontDUrville"
"FALSE" "Antarctica/Macquarie"
"FALSE" "Antarctica/Mawson"
"FALSE" "Antarctica/McMurdo"
"FALSE" "Antarctica/Palmer"
"FALSE" "Antarctica/Rothera"
"FALSE" "Antarctica/South_Pole"
"FALSE" "Antarctica/Syowa"
"FALSE" "Antarctica/Troll"
"FALSE" "Antarctica/Vostok"
"FALSE" "Arctic/Longyearbyen"
"FALSE" "Asia/Aden"
"FALSE" "Asia/Almaty"
"FALSE" "Asia/Amman"
"FALSE" "Asia/Anadyr"
"FALSE" "Asia/Aqtau"
"FALSE" "Asia/Aqtobe"
"FALSE" "Asia/Ashgabat"
"FALSE" "Asia/Ashkhabad"
"FALSE" "Asia/Atyrau"
"FALSE" "Asia/Baghdad"
"FALSE" "Asia/Bahrain"
"FALSE" "Asia/Baku"
"FALSE" "Asia/Bangkok"
"FALSE" "Asia/Barnaul"
"FALSE" "Asia/Beirut"
"FALSE" "Asia/Bishkek"
"FALSE" "Asia/Brunei"
"FALSE" "Asia/Calcutta"
"FALSE" "Asia/Chita"
"FALSE" "Asia/Choibalsan"
"FALSE" "Asia/Chongqing"
"FALSE" "Asia/Chungking"
"FALSE" "Asia/Colombo"
"FALSE" "Asia/Dacca"
"FALSE" "Asia/Damascus"
"FALSE" "Asia/Dhaka"
"FALSE" "Asia/Dili"
"FALSE" "Asia/Dubai"
"FALSE" "Asia/Dushanbe"
"FALSE" "Asia/Famagusta"
"FALSE" "Asia/Gaza"
"FALSE" "Asia/Harbin"
"FALSE" "Asia/Hebron"
"FALSE" "Asia/Ho_Chi_Minh"
"FALSE" "Asia/Hong_Kong"
"FALSE" "Asia/Hovd"
"FALSE" "Asia/Irkutsk"
"FALSE" "Asia/Istanbul"
"FALSE" "Asia/Jakarta"
"FALSE" "Asia/Jayapura"
"FALSE" "Asia/Jerusalem"
"FALSE" "Asia/Kabul"
"FALSE" "Asia/Kamchatka"
"FALSE" "Asia/Karachi"
"FALSE" "Asia/Kashgar"
"FALSE" "Asia/Kathmandu"
"FALSE" "Asia/Katmandu"
"FALSE" "Asia/Khandyga"
"FALSE" "Asia/Kolkata"
"FALSE" "Asia/Krasnoyarsk"
"FALSE" "Asia/Kuala_Lumpur"
"FALSE" "Asia/Kuching"
"FALSE" "Asia/Kuwait"
"FALSE" "Asia/Macao"
"FALSE" "Asia/Macau"
"FALSE" "Asia/Magadan"
"FALSE" "Asia/Makassar"
"FALSE" "Asia/Manila"
"FALSE" "Asia/Muscat"
"FALSE" "Asia/Nicosia"
"FALSE" "Asia/Novokuznetsk"
"FALSE" "Asia/Novosibirsk"
"FALSE" "Asia/Omsk"
"FALSE" "Asia/Oral"
"FALSE" "Asia/Phnom_Penh"
"FALSE" "Asia/Pontianak"
"FALSE" "Asia/Pyongyang"
"FALSE" "Asia/Qatar"
"FALSE" "Asia/Qostanay"
"FALSE" "Asia/Qyzylorda"
"FALSE" "Asia/Rangoon"
"FALSE" "Asia/Riyadh"
"FALSE" "Asia/Saigon"
"FALSE" "Asia/Sakhalin"
"FALSE" "Asia/Samarkand"
"FALSE" "Asia/Seoul"
"FALSE" "Asia/Shanghai"
"FALSE" "Asia/Singapore"
"FALSE" "Asia/Srednekolymsk"
"FALSE" "Asia/Taipei"
"FALSE" "Asia/Tashkent"
"FALSE" "Asia/Tbilisi"
"FALSE" "Asia/Tehran"
"FALSE" "Asia/Tel_Aviv"
"FALSE" "Asia/Thimbu"
"FALSE" "Asia/Thimphu"
"FALSE" "Asia/Tokyo"
"FALSE" "Asia/Tomsk"
"FALSE" "Asia/Ujung_Pandang"
"FALSE" "Asia/Ulaanbaatar"
"FALSE" "Asia/Ulan_Bator"
"FALSE" "Asia/Urumqi"
"FALSE" "Asia/Ust-Nera"
"FALSE" "Asia/Vientiane"
"FALSE" "Asia/Vladivostok"
"FALSE" "Asia/Yakutsk"
"FALSE" "Asia/Yangon"
"FALSE" "Asia/Yekaterinburg"
"FALSE" "Asia/Yerevan"
"FALSE" "Atlantic/Azores"
"FALSE" "Atlantic/Bermuda"
"FALSE" "Atlantic/Canary"
"FALSE" "Atlantic/Cape_Verde"
"FALSE" "Atlantic/Faeroe"
"FALSE" "Atlantic/Faroe"
"FALSE" "Atlantic/Jan_Mayen"
"FALSE" "Atlantic/Madeira"
"FALSE" "Atlantic/Reykjavik"
"FALSE" "Atlantic/South_Georgia"
"FALSE" "Atlantic/St_Helena"
"FALSE" "Atlantic/Stanley"
"FALSE" "Australia/ACT"
"FALSE" "Australia/Adelaide"
"FALSE" "Australia/Brisbane"
"FALSE" "Australia/Broken_Hill"
"FALSE" "Australia/Canberra"
"FALSE" "Australia/Currie"
"FALSE" "Australia/Darwin"
"FALSE" "Australia/Eucla"
"FALSE" "Australia/Hobart"
"FALSE" "Australia/LHI"
"FALSE" "Australia/Lindeman"
"FALSE" "Australia/Lord_Howe"
"FALSE" "Australia/Melbourne"
"FALSE" "Australia/NSW"
"FALSE" "Australia/North"
"FALSE" "Australia/Perth"
"FALSE" "Australia/Queensland"
"FALSE" "Australia/South"
"FALSE" "Australia/Sydney"
"FALSE" "Australia/Tasmania"
"FALSE" "Australia/Victoria"
"FALSE" "Australia/West"
"FALSE" "Australia/Yancowinna"
"FALSE" "Brazil/Acre"
"FALSE" "Brazil/DeNoronha"
"FALSE" "Brazil/East"
"FALSE" "Brazil/West"
"FALSE" "CET"
"FALSE" "CST6CDT"
"FALSE" "Canada/Atlantic"
"FALSE" "Canada/Central"
"FALSE" "Canada/Eastern"
"FALSE" "Canada/Mountain"
"FALSE" "Canada/Newfoundland"
"FALSE" "Canada/Pacific"
"FALSE" "Canada/Saskatchewan"
"FALSE" "Canada/Yukon"
"FALSE" "Chile/Continental"
"FALSE" "Chile/EasterIsland"
"FALSE" "Cuba"
"FALSE" "EET"
"FALSE" "EST"
"FALSE" "EST5EDT"
"FALSE" "Egypt"
"FALSE" "Eire"
"FALSE" "Europe/Amsterdam"
"FALSE" "Europe/Andorra"
"FALSE" "Europe/Astrakhan"
"FALSE" "Europe/Athens"
"FALSE" "Europe/Belfast"
"FALSE" "Europe/Belgrade"
"FALSE" "Europe/Berlin"
"FALSE" "Europe/Bratislava"
"FALSE" "Europe/Brussels"
"FALSE" "Europe/Bucharest"
"FALSE" "Europe/Budapest"
"FALSE" "Europe/Busingen"
"FALSE" "Europe/Chisinau"
"FALSE" "Europe/Copenhagen"
"FALSE" "Europe/Dublin"
"FALSE" "Europe/Gibraltar"
"FALSE" "Europe/Guernsey"
"FALSE" "Europe/Helsinki"
"FALSE" "Europe/Isle_of_Man"
"FALSE" "Europe/Istanbul"
"FALSE" "Europe/Jersey"
"FALSE" "Europe/Kaliningrad"
"FALSE" "Europe/Kiev"
"FALSE" "Europe/Kirov"
"FALSE" "Europe/Kyiv"
"FALSE" "Europe/Lisbon"
"FALSE" "Europe/Ljubljana"
"FALSE" "Europe/London"
"FALSE" "Europe/Luxembourg"
"FALSE" "Europe/Madrid"
"FALSE" "Europe/Malta"
"FALSE" "Europe/Mariehamn"
"FALSE" "Europe/Minsk"
"FALSE" "Europe/Monaco"
"FALSE" "Europe/Moscow"
"FALSE" "Europe/Nicosia"
"FALSE" "Europe/Oslo"
"FALSE" "Europe/Paris"
"FALSE" "Europe/Podgorica"
"FALSE" "Europe/Prague"
"FALSE" "Europe/Riga"
"FALSE" "Europe/Rome"
"FALSE" "Europe/Samara"
"FALSE" "Europe/San_Marino"
"FALSE" "Europe/Sarajevo"
"FALSE" "Europe/Saratov"
"FALSE" "Europe/Simferopol"
"FALSE" "Europe/Skopje"
"FALSE" "Europe/Sofia"
"FALSE" "Europe/Stockholm"
"FALSE" "Europe/Tallinn"
"FALSE" "Europe/Tirane"
"FALSE" "Europe/Tiraspol"
"FALSE" "Europe/Ulyanovsk"
"FALSE" "Europe/Uzhgorod"
"FALSE" "Europe/Vaduz"
"FALSE" "Europe/Vatican"
"FALSE" "Europe/Vienna"
"FALSE" "Europe/Vilnius"
"FALSE" "Europe/Volgograd"
"FALSE" "Europe/Warsaw"
"FALSE" "Europe/Zagreb"
"FALSE" "Europe/Zaporozhye"
"FALSE" "Europe/Zurich"
"FALSE" "Factory"
"FALSE" "GB"
"FALSE" "GB-Eire"
"FALSE" "GMT"
"FALSE" "GMT+0"
"FALSE" "GMT-0"
"FALSE" "GMT0"
"FALSE" "Greenwich"
"FALSE" "HST"
"FALSE" "Hongkong"
"FALSE" "Iceland"
"FALSE" "Indian/Antananarivo"
"FALSE" "Indian/Chagos"
"FALSE" "Indian/Christmas"
"FALSE" "Indian/Cocos"
"FALSE" "Indian/Comoro"
"FALSE" "Indian/Kerguelen"
"FALSE" "Indian/Mahe"
"FALSE" "Indian/Maldives"
"FALSE" "Indian/Mauritius"
"FALSE" "Indian/Mayotte"
"FALSE" "Indian/Reunion"
"FALSE" "Iran"
"FALSE" "Israel"
"FALSE" "Jamaica"
"FALSE" "Japan"
"FALSE" "Kwajalein"
"FALSE" "Libya"
"FALSE" "MET"
"FALSE" "MST"
"FALSE" "MST7MDT"
"FALSE" "Mexico/BajaNorte"
"FALSE" "Mexico/BajaSur"
"FALSE" "Mexico/General"
"FALSE" "NZ"
"FALSE" "NZ-CHAT"
"FALSE" "Navajo"
"FALSE" "PRC"
"FALSE" "PST8PDT"
"FALSE" "Pacific/Apia"
"FALSE" "Pacific/Auckland"
"FALSE" "Pacific/Bougainville"
"FALSE" "Pacific/Chatham"
"FALSE" "Pacific/Chuuk"
"FALSE" "Pacific/Easter"
"FALSE" "Pacific/Efate"
"FALSE" "Pacific/Enderbury"
"FALSE" "Pacific/Fakaofo"
"FALSE" "Pacific/Fiji"
"FALSE" "Pacific/Funafuti"
"FALSE" "Pacific/Galapagos"
"FALSE" "Pacific/Gambier"
"FALSE" "Pacific/Guadalcanal"
"FALSE" "Pacific/Guam"
"FALSE" "Pacific/Honolulu"
"FALSE" "Pacific/Johnston"
"FALSE" "Pacific/Kanton"
"FALSE" "Pacific/Kiritimati"
"FALSE" "Pacific/Kosrae"
"FALSE" "Pacific/Kwajalein"
"FALSE" "Pacific/Majuro"
"FALSE" "Pacific/Marquesas"
"FALSE" "Pacific/Midway"
"FALSE" "Pacific/Nauru"
"FALSE" "Pacific/Niue"
"FALSE" "Pacific/Norfolk"
"FALSE" "Pacific/Noumea"
"FALSE" "Pacific/Pago_Pago"
"FALSE" "Pacific/Palau"
"FALSE" "Pacific/Pitcairn"
"FALSE" "Pacific/Pohnpei"
"FALSE" "Pacific/Ponape"
"FALSE" "Pacific/Port_Moresby"
"FALSE" "Pacific/Rarotonga"
"FALSE" "Pacific/Saipan"
"FALSE" "Pacific/Samoa"
"FALSE" "Pacific/Tahiti"
"FALSE" "Pacific/Tarawa"
"FALSE" "Pacific/Tongatapu"
"FALSE" "Pacific/Truk"
"FALSE" "Pacific/Wake"
"FALSE" "Pacific/Wallis"
"FALSE" "Pacific/Yap"
"FALSE" "Poland"
"FALSE" "Portugal"
"FALSE" "ROC"
"FALSE" "ROK"
"FALSE" "Singapore"
"FALSE" "Turkey"
"FALSE" "UCT"
"FALSE" "US/Alaska"
"FALSE" "US/Aleutian"
"FALSE" "US/Arizona"
"FALSE" "US/Central"
"FALSE" "US/East-Indiana"
"FALSE" "US/Eastern"
"FALSE" "US/Hawaii"
"FALSE" "US/Indiana-Starke"
"FALSE" "US/Michigan"
"FALSE" "US/Mountain"
"FALSE" "US/Pacific"
"FALSE" "US/Samoa"
"FALSE" "Universal"
"FALSE" "W-SU"
"FALSE" "WET"
"FALSE" "Zulu"
)


chroot_ChromeOS-Flex()
{
cat >"${bootstrapdir}"/tmp/linuxloops/prepare_bootstrap <<PREPARE_BOOTSTRAP
#!/bin/bash
set -e
sed -i 's@#ParallelDownloads@ParallelDownloads@g' /etc/pacman.conf
curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://archlinux.org/mirrorlist/?ip_version=4 -o /etc/pacman.d/mirrorlist
if [ ! -z "${mirror_Arch}" ]; then
	echo 'Server = ${mirror_Arch}/\$repo/os/\$arch' >> /etc/pacman.d/mirrorlist
else
	cur_speed=0; for i in https://geo.mirror.pkgbuild.com https://mirrors.rit.edu/archlinux https://archlinux.mirror.digitalpacific.com.au; do if ! avg_speed=\$(curl -fsS -m 5 -r 0-1048576 -w '%{speed_download}' -o /dev/null --url "\${i}/core/os/x86_64/core.db" 2> /dev/null); then avg_speed=0; fi; echo Download speed rating for mirror \${i} is \${avg_speed}; if [ \${avg_speed} -gt \${cur_speed} ]; then cur_speed=\${avg_speed}; default_mirror=\${i}; fi; done; echo Using mirror \${default_mirror}; sed -i "s@#Server = \${default_mirror}@Server = \${default_mirror}@g" /etc/pacman.d/mirrorlist
fi
pacman -Syu --noconfirm --needed bash bash-completion busybox bzip2 ca-certificates coreutils cpio cryptsetup curl dosfstools e2fsprogs efibootmgr gzip libarchive lsof nano ntfs-3g openssl sbsigntools sudo strace tar util-linux unzip xz zstd
PREPARE_BOOTSTRAP
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/prepare_bootstrap

cat >"${bootstrapdir}"/tmp/linuxloops/prepare_chroot <<PREPARE_CHROOT
#!/bin/bash
set -e
/tmp/linuxloops/install_script
PREPARE_CHROOT
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/prepare_chroot

if [ "${environment}" == "Devmode" ]; then dev_mode="cros_debug"; fi

cat >"${bootstrapdir}"/tmp/linuxloops/install_script <<INSTALL_SCRIPT
#!/bin/bash
set -euo pipefail

bin_path='${bin_path}'
partition_path='${partition_path}'

mkdir -p /isomount/data /isomount/roota /isomount/rootc /isomount/efi /isomount/tmp
mkfs.ext4 -E nodiscard -F -L "H-STATE" "\${partition_path}1"
mount "\${partition_path}1" /isomount/data

recovery_bin="/isomount/data/recovery.bin"
recovery_zip="/isomount/data/recovery.zip"

if [ -n "\${bin_path}" ]; then
	echo "Using local recovery image: \${bin_path}"
	[ -f "\${bin_path}" ] || { echo "Fichier introuvable: \${bin_path}" >&2; exit 1; }
	cp "\${bin_path}" "\${recovery_bin}"
else
	echo "Downloading ChromeOS-Flex recovery image"

	conf_url="https://dl.google.com/dl/edgedl/chromeos/recovery/cloudready_recovery.conf"

	for i in 1 2 3; do
		conf="\$(curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f "\${conf_url}")"

		download_url="\$(
			printf '%s\n' "\${conf}" \
			| tr '\n' ' ' \
			| sed 's@  @ \n\n@g' \
			| grep reven \
			| tail -1 \
			| tr ' ' '\n' \
			| grep '^url=' \
			| cut -d'=' -f2
		)"

		expected_sha1="\$(
			printf '%s\n' "\${conf}" \
			| tr '\n' ' ' \
			| sed 's@  @ \n\n@g' \
			| grep reven \
			| tail -1 \
			| tr ' ' '\n' \
			| grep '^sha1=' \
			| cut -d'=' -f2
		)"

		if curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f "\${download_url}" -o "\${recovery_zip}"; then
			actual_sha1="\$(sha1sum "\${recovery_zip}" | cut -d' ' -f1)"
			if [ "\${actual_sha1}" = "\${expected_sha1}" ]; then
				echo "sha1sum verification succeeded"
				unzip -p "\${recovery_zip}" > "\${recovery_bin}"
				break
			else
				echo "sha1sum verification failed, retrying download..."
			fi
		fi

		if [ "\${i}" -eq 3 ]; then
			echo "Download of ChromeOS-Flex recovery image failed" >&2
			exit 1
		fi
	done
fi

echo "Recovery image ready: \${recovery_bin}"

bsdtar -xvf /isomount/data/recovery.zip -C /root || { echo -e "Failed to extract the recovery image."; return 1; }
rm -f /isomount/data/recovery.zip
isomount="\$(losetup --show -fP \$(ls /root/chromeos_*.bin))"
for (( i=1; i<=12; i++ )); do
	(echo "x"; echo "u"; echo "\${i}"; echo "\$(blkid -o value -s PARTUUID "\${isomount}"p"\${i}")"; echo "r"; sleep 5; echo "w") | fdisk "${destination_device}" || { echo -e "Partition UUID update failed. Exiting.\n"; exit 1; }
	case \${i} in
		1)
			continue
		;;
		2)
			part_source=4
		;;
		7)
			mkfs.ext4 -E nodiscard -F -L "ROOT-C" "${partition_path}""\${i}"
			if tune2fs -l "${partition_path}""\${i}" | grep 'Filesystem features' | grep -q -w large_dir; then tune2fs -O ^large_dir "${partition_path}""\${i}"; fi
			if tune2fs -l "${partition_path}""\${i}" | grep 'Filesystem features' | grep -q -w metadata_csum_seed; then tune2fs -O ^metadata_csum_seed "${partition_path}""\${i}"; fi
			if tune2fs -l "${partition_path}""\${i}" | grep 'Filesystem features' | grep -q -w orphan_file; then tune2fs -O ^orphan_file "${partition_path}""\${i}"; fi
			continue
		;;
		12)
			mount "\${isomount}"p12 /isomount/tmp
			mkfs.fat -F32 -n 'EFI' "${partition_path}""\${i}"
			mount "${partition_path}""\${i}" /isomount/efi
			cp -r /isomount/tmp/* /isomount/efi/
			if [ "${install_type}" == "image" ]; then
				mkdir -p /mnt/etc/secureboot_key
				sbattach --signum 1 --detach /mnt/etc/secureboot_key/MOK.tmp /isomount/efi/syslinux/vmlinuz.A
				openssl pkcs7 -print_certs -inform der -in /mnt/etc/secureboot_key/MOK.tmp -out /mnt/etc/secureboot_key/MOK.pem
				openssl x509 -outform DER -in /mnt/etc/secureboot_key/MOK.pem -out /mnt/etc/secureboot_key/MOK.der
			fi
			umount /isomount/efi
			umount /isomount/tmp
			continue
		;;
		*)
			part_source="\${i}"
		;;
	esac
	dd if="\${isomount}"p"\${part_source}" of="${partition_path}""\${i}" bs=1M conv=notrunc status=progress
done
printf '\000' | dd of="\${isomount}"p3 seek=\$((0x464 + 3)) conv=notrunc count=1 bs=1 status=none
mount "\${isomount}"p3 /mnt
mount --bind /proc /mnt/proc
mount --make-slave /mnt/proc
mount --bind /sys /mnt/sys
mount --make-slave /mnt/sys
mount --bind /dev /mnt/dev
mount --make-slave /mnt/dev
chroot /mnt /bin/bash <<'GPT_PRIORITY'
cgpt add -i 2 -S 0 -T 15 -P 15 "${destination_device}"
cgpt add -i 4 -S 0 -T 15 -P 0 "${destination_device}"
cgpt add -i 6 -S 0 -T 15 -P 0 "${destination_device}"
GPT_PRIORITY
umount /mnt/sys
umount /mnt/proc
umount /mnt/dev
umount /mnt
losetup -d "\${isomount}"
rm -rf /isomount/data/*
umount /isomount/data
if [ "${install_type}" == "image" ]; then
	mount "${partition_path}"7 /isomount/rootc
	mkdir -p /isomount/rootc/initramfs
	cd /isomount/rootc/initramfs
	mkdir -p etc proc sys tmp usr/bin usr/lib usr/mbin usr/sbin
	ln -s /usr/bin bin
	ln -s /usr/lib lib
	ln -s /usr/lib lib64
	ln -s /usr/sbin sbin
	for i in \$(ldd /usr/bin/bash | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/bash ./usr/bin/
	for i in \$(ldd /usr/bin/busybox | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/busybox ./usr/bin/
	for i in \$(ldd /usr/bin/blkid | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/blkid ./usr/mbin/
	for i in \$(ldd /usr/bin/e2fsck | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/e2fsck ./usr/mbin/
	for i in \$(ldd /usr/bin/losetup | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/losetup ./usr/mbin/
	for i in \$(ldd /usr/bin/mkfs.ext4 | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/mkfs.ext4 ./usr/mbin/
	for i in \$(ldd /usr/bin/modprobe | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/modprobe ./usr/mbin/
	for i in \$(ldd /usr/bin/ntfs-3g | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/ntfs-3g ./usr/mbin/
	for i in \$(ldd /usr/bin/ntfsfix | cut -d' ' -f3); do cp "\${i}" ./usr/lib/; done
	cp -a /usr/bin/ntfsfix ./usr/mbin/
	cp -a /usr/lib/ld-linux-x86-64.so.2 ./usr/lib/
	cp -a /usr/lib/libgcc_s.so.1 ./usr/lib/
	cat >./init <<'INITSCRIPT'
#!/usr/bin/bash
export PATH=/usr/mbin:/usr/sbin:/usr/bin
export LD_LIBRARY_PATH=/usr/lib

busybox mount -t proc none /proc
busybox mount -t sysfs none /sys
busybox mount -t devtmpfs none /dev
busybox --install -s
ln -s /proc/mounts /etc/mtab

if [ ! -z "\$linuxloops_debug" ] && [ "\$linuxloops_debug" -eq 1 ]; then
	echo 0 0 0 0 > /proc/sys/kernel/printk
	exec sh
fi

if { [ ! -z "\$img_uuid" ] || [ ! -z "\$img_part" ]; } && [ ! -z "\$img_path" ]; then
	linuxloops_timeout=0
	until false; do
		if [ ! -z "\$img_uuid" ]; then img_part="\$(blkid --match-token PARTUUID=\$img_uuid | cut -d':' -f1)"; fi
		echo "\$img_uuid | \$img_part"
		if [ -b "\$img_part" ]; then break; fi
		if [ \$linuxloops_timeout == 10 ]; then echo "The boot partition was not found, falling back to shell..." > /dev/kmsg; exec sh; fi
		linuxloops_timeout=\$(( \$linuxloops_timeout + 1 ))
		sleep 1
	done
else
	echo "The grub configuration is invalid, falling back to shell..." > /dev/kmsg
	exec sh
fi

if [ -e "\$img_part" ] && [ ! -z "\$img_path" ]; then
	mkdir /mainroot
	fstype=\$(blkid -s TYPE -o value "\$img_part")
	if [ "\$fstype" == "ntfs" ]; then
		ntfs-3g "\$img_part" /mainroot
	else
		mount -n "\$img_part" /mainroot
	fi
	if [ -f /mainroot/"\$img_path" ]; then
		if [ ! -b /dev/loop0 ]; then mknod -m660 /dev/loop0 b 7 0; fi
		losetup --direct-io=off -P /dev/loop0 /mainroot"\$img_path"
		bootdevice=/dev/loop0
	else
		echo "linuxloops: ChromeOS loopfile \$img_path not found on device \$img_part..." > /dev/kmsg
		exec sh
	fi
fi

if [ ! -z "\$linuxloops_debug" ] && [ "\$linuxloops_debug" -eq 2 ]; then
	echo 0 0 0 0 > /proc/sys/kernel/printk
	exec sh
fi

if [ "\$bootimage" == "B" ]; then bootpart=5; else bootpart=3; fi
printf '\000' | dd of="\$bootdevice"p"\$bootpart" seek=\$((0x464 + 3)) conv=notrunc count=1 bs=1 status=none
mkdir -p chromeosroot
mount "\$bootdevice"p"\$bootpart" /chromeosroot

touch /chromeosroot/.nodelta
cat >/chromeosroot/sbin/chromeos_startup <<'STARTUP'
#!/bin/bash

mount_or_fail()
{
	echo "mount_or_fail was called with the following arguments: \$@"
	if ! mount \$@; then reboot -f; fi
}

mount_with_log()
{
	echo "mount_with_log was called with the following arguments: \$@"
	mount \$@
}

exec 1>>/root/brunch_startup_log
exec 2>>/root/brunch_startup_log
echo "Brunch startup:"

systemd-tmpfiles --create --remove --boot --prefix /dev --prefix /proc --prefix /run

mount_with_log -t debugfs -o nosuid,nodev,noexec,mode=0750,uid=0,gid=\$(cat /etc/group | grep '^debugfs-access:' | cut -d':' -f3) debugfs /sys/kernel/debug
mount_with_log -t tracefs -o nosuid,nodev,noexec,mode=0755 tracefs /sys/kernel/tracing
mount_with_log -t configfs -o nosuid,nodev,noexec configfs /sys/kernel/config
mount_with_log -t bpf -o nosuid,nodev,noexec,mode=0770,gid=\$(cat /etc/group | grep '^bpf-access:' | cut -d':' -f3) bpf /sys/fs/bpf
mount_with_log -t securityfs -o nosuid,nodev,noexec securityfs /sys/kernel/security
sysctl -q --system
mount_with_log -o bind /run/namespaces /run/namespaces
mount_with_log --make-private /run/namespaces

#sed '/^#/d' /usr/share/cros/startup/process_management_policies/*gid_allowlist.txt 2>/dev/null | sed -r '/^\s*\$/d' > /sys/kernel/security/safesetid/gid_allowlist_policy
#sed '/^#/d' /usr/share/cros/startup/process_management_policies/*uid_allowlist.txt 2>/dev/null | sed -r '/^\s*\$/d' > /sys/kernel/security/safesetid/uid_allowlist_policy
#echo '/var' > /sys/kernel/security/chromiumos/inode_security_policies/block_symlink
#echo '/var' > /sys/kernel/security/chromiumos/inode_security_policies/block_fifo
#echo '/var/lib/timezone' > /sys/kernel/security/chromiumos/inode_security_policies/allow_symlink
#echo '/var/log' > /sys/kernel/security/chromiumos/inode_security_policies/allow_symlink
#echo '/home' > /sys/kernel/security/chromiumos/inode_security_policies/allow_symlink
#cat /dev/null > /sys/kernel/security/loadpin/dm-verity

data_partition="\$(df -h --output=source / | tail -1 | sed 's/.\$//')1"
if [ ! -b \$data_partition ]; then echo "data partition \$data_partition was not found."; reboot -f; fi
tune2fs -g 20119 -O encrypt,project,quota,verity -Q usrquota,grpquota,prjquota \$data_partition
mount_or_fail -o nosuid,nodev,noexec,noatime,commit=600,discard \$data_partition /mnt/stateful_partition
if [ -f /mnt/stateful_partition/factory_install_reset ]; then echo "the factory_install_reset file triggered a powerwash."; rm -rf /mnt/stateful_partition/{*,.*}; fi
mount_with_log -o ro,nosuid,nodev,noexec /dev/loop0p8 /usr/share/oem
systemd-tmpfiles --create --remove --boot --prefix /mnt/stateful_partition
mount_or_fail -o bind /mnt/stateful_partition/home /home
mount_with_log -o remount,nosuid,nodev,noexec,nosymfollow /home
if [ -f /etc/init/tpm2-simulator.conf ]; then initctl start tpm2-simulator; fi
mkdir -p /mnt/stateful_partition/encrypted/chronos /mnt/stateful_partition/encrypted/var
chmod 0755 /mnt/stateful_partition/encrypted/chronos /mnt/stateful_partition/encrypted/var
mount_or_fail -o bind /mnt/stateful_partition/encrypted /mnt/stateful_partition/encrypted
mount_or_fail -o bind /mnt/stateful_partition/encrypted/chronos /home/chronos
mount_or_fail -o bind /mnt/stateful_partition/encrypted/var /var
rm -r /var/log
systemd-tmpfiles --create --remove --boot --prefix /home --prefix /var
mount_with_log -o bind /run /var/run
mount_with_log -o bind /run/lock /var/lock

for d in /etc/daemon-store/*/; do
	mkdir -p /run/daemon-store/\$(basename \$d)
	chmod 0755 /run/daemon-store/\$(basename \$d)
	mount_with_log -o bind /run/daemon-store/\$(basename \$d) /run/daemon-store/\$(basename \$d)
	mount_with_log --make-shared /run/daemon-store/\$(basename \$d)
	mkdir -p /run/daemon-store-cache/\$(basename \$d)
	chmod 0755 /run/daemon-store-cache/\$(basename \$d)
	mount_with_log -o bind /run/daemon-store-cache/\$(basename \$d) /run/daemon-store-cache/\$(basename \$d)
	mount_with_log --make-shared /run/daemon-store-cache/\$(basename \$d)
done

mount_with_log -t tmpfs -o nosuid,nodev,noexec media /media
mount_with_log --make-shared /media
systemd-tmpfiles --create --remove --boot --prefix /media

restorecon -r /home/chronos /home/root /home/user /sys/devices/system/cpu /var
for f in /home/.shadow/*; do if [ -f \$f ]; then restorecon \$f; fi; done
for f in /home/.shadow/.*; do if [ -f \$f ]; then restorecon \$f; fi; done
for f in /home/.shadow/*/*; do if [ -f \$f ]; then restorecon \$f; fi; done

mkdir -p /var/log/asan
chmod 1777 /var/log/asan
mkdir -p /mnt/stateful_partition/dev_image
chmod 0755 /mnt/stateful_partition/dev_image
mount_with_log -o bind /mnt/stateful_partition/dev_image /usr/local
mount_with_log -o remount,suid,dev,exec /usr/local
if [ -d /mnt/stateful_partition/var_overlay/cache/dlc-images ]; then mount_with_log -o bind /mnt/stateful_partition/var_overlay/cache/dlc-images /var/cache/dlc-images; fi
if [ -d /mnt/stateful_partition/var_overlay/db/pkg ]; then mount_with_log -o bind /mnt/stateful_partition/var_overlay/db/pkg /var/db/pkg; fi
if [ -d /mnt/stateful_partition/var_overlay/lib/portage ]; then mount_with_log -o bind /mnt/stateful_partition/var_overlay/lib/portage /var/lib/portage; fi

mount_with_log -o remount,ro /sys/kernel/security

exit 0
STARTUP
chmod 0755 /chromeosroot/sbin/chromeos_startup
if [ ! -f /chromeosroot/usr/bin/chroot.real ]; then
	mv /chromeosroot/usr/bin/chroot /chromeosroot/usr/bin/chroot.real
	cat >/chromeosroot/usr/bin/chroot <<'CHROOT'
#!/bin/bash
set -e
if [ "\$EUID" -eq 0 ] && [ "\${1}" == "." ] && [ "\${2}" == "/usr/bin/cros_installer" ]; then
	rootpath=\$(echo "\$(rootdev)" | sed 's/.\$//')
	rm -rf /mnt/stateful_partition/newroot /mnt/stateful_partition/rootc
	mkdir -p /mnt/stateful_partition/newroot /mnt/stateful_partition/rootc
	mount "\$rootpath"7 /mnt/stateful_partition/rootc
	find ./lib/firmware | bsdcpio -o -H newc > /mnt/stateful_partition/rootc/firmwares.img
	find ./lib/modules | bsdcpio -o -H newc > /mnt/stateful_partition/rootc/modules.img
	if [ "\$(rootdev)" == "\$rootpath"3 ]; then
		echo "bootimage=B" > /mnt/stateful_partition/rootc/bootimage.cfg
	else
		echo "bootimage=A" > /mnt/stateful_partition/rootc/bootimage.cfg
	fi
	umount /mnt/stateful_partition/rootc
	chroot.real "\$@"
else
	chroot.real "\$@"
fi
CHROOT
	chmod 0755 /chromeosroot/usr/bin/chroot
fi

umount /chromeosroot
printf '\377' | dd of="\$bootdevice"p"\$bootpart" seek=\$((0x464 + 3)) conv=notrunc count=1 bs=1 status=none
mount -o ro "\$bootdevice"p"\$bootpart" /chromeosroot

mount --move /dev /chromeosroot/dev
mount --move /sys /chromeosroot/sys
mount --move /proc /chromeosroot/proc

sync

if [ ! -z "\$linuxloops_debug" ] && [ "\$linuxloops_debug" -eq 3 ]; then
	echo 0 0 0 0 > /roota/proc/sys/kernel/printk
	exec sh
fi

exec switch_root /chromeosroot /sbin/init "\$@"
INITSCRIPT
	chmod 0755 ./init
	find . | cpio -o -H newc > /isomount/rootc/initramfs.img
	mount -o ro "${partition_path}"3 /isomount/roota
	(cd /isomount/roota; find ./lib/firmware | cpio -o -H newc > /isomount/rootc/firmwares.img)
	(cd /isomount/roota; find ./lib/modules | cpio -o -H newc > /isomount/rootc/modules.img)
	umount /isomount/roota
	cd ../../..
	rm -r /isomount/rootc/initramfs
	umount /isomount/rootc
fi
INSTALL_SCRIPT
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_script
}


generate_bootstrap_init()
{
cat >"${bootstrapdir}"/tmp/linuxloops/bootstrap_init <<INITCHROOT
#!/bin/bash
set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib/x86_64-linux-gnu:/usr/local/lib:/usr/lib64:/usr/lib/x86_64-linux-gnu:/usr/lib:/lib64:/lib/x86_64-linux-gnu:/lib
if [ -x /tmp/linuxloops/prepare_bootstrap ]; then /tmp/linuxloops/prepare_bootstrap; fi
if [ -x /tmp/linuxloops/partition_script ]; then /tmp/linuxloops/partition_script; fi
if [ -x /tmp/linuxloops/setup_and_mount_rootfs ]; then /tmp/linuxloops/setup_and_mount_rootfs; fi
rm -f /tmp/linuxloops/setup_and_mount_rootfs
if [ -x /tmp/linuxloops/mount_efi ]; then /tmp/linuxloops/mount_efi; fi
if [ -x /tmp/linuxloops/prepare_chroot ]; then /tmp/linuxloops/prepare_chroot; fi
if ([ ! -z "${github}" ] && [ "${distribution}" == "Bazzite" ]) || ([ ! -z "${github}" ] && [ "${distribution}" == "Fedora-Atomic" ]); then exit 0; fi
if [ -x /tmp/linuxloops/enter_chroot ]; then /tmp/linuxloops/enter_chroot; fi
if [ -x /tmp/linuxloops/efi_entry ]; then /tmp/linuxloops/efi_entry; fi
INITCHROOT
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/bootstrap_init
}

generate_partition_script()
{
if [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/partition_script <<PARTITIONDEVICE
#!/bin/bash
set -e
if [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ]; then
	(echo "g"; echo "n"; echo "2"; echo ""; echo "+64M"; echo "t"; echo "FE3A2A5D-4F32-41A7-B725-ACCC3285A309"; echo "x"; echo "n"; echo "KERN-A"; echo "r"; echo "n"; echo "3"; echo ""; echo "+4G"; echo "t"; echo "3"; echo "3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC"; echo "x"; echo "n"; echo "3"; echo "ROOT-A"; echo "r"; echo "n"; echo "4"; echo ""; echo "+64M"; echo "t"; echo "4"; echo "FE3A2A5D-4F32-41A7-B725-ACCC3285A309"; echo "x"; echo "n"; echo "4"; echo "KERN-B"; echo "r"; echo "n"; echo "5"; echo ""; echo "+4G"; echo "t"; echo "5"; echo "3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC"; echo "x"; echo "n"; echo "5"; echo "ROOT-B"; echo "r"; echo "n"; echo "6"; echo ""; echo "+1K"; echo "t"; echo "6"; echo "FE3A2A5D-4F32-41A7-B725-ACCC3285A309"; echo "x"; echo "n"; echo "6"; echo "KERN-C"; echo "r"; echo "n"; echo "7"; echo ""; echo "+1G"; echo "t"; echo "7"; echo "3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC"; echo "x"; echo "n"; echo "7"; echo "ROOT-C"; echo "r"; echo "n"; echo "8"; echo ""; echo "+16M"; echo "t"; echo "8"; echo "0FC63DAF-8483-4772-8E79-3D69D8477DE4"; echo "x"; echo "n"; echo "8"; echo "OEM"; echo "r"; echo "n"; echo "9"; echo ""; echo "+1K"; echo "t"; echo "9"; echo "2E0A753D-9E48-43B0-8337-B15192CB1B5E"; echo "x"; echo "n"; echo "9"; echo "reserved"; echo "r"; echo "n"; echo "10"; echo ""; echo "+1K"; echo "t"; echo "10"; echo "2E0A753D-9E48-43B0-8337-B15192CB1B5E"; echo "x"; echo "n"; echo "10"; echo "reserved"; echo "r"; echo "n"; echo "11"; echo ""; echo "+8M"; echo "t"; echo "11"; echo "CAB6E88E-ABF3-4102-A07A-D4BB9BE3C1D3"; echo "x"; echo "n"; echo "11"; echo "RWFW"; echo "r"; echo "n"; echo "12"; echo ""; echo "+64M"; echo "t"; echo "12"; echo "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"; echo "x"; echo "n"; echo "12"; echo "EFI-SYSTEM"; echo "r"; echo "n"; echo "1"; echo ""; echo "+$(( ${install_sizeMB} - 9434 - 3 ))M"; echo "t"; echo "1"; echo "0FC63DAF-8483-4772-8E79-3D69D8477DE4"; echo "x"; echo "n"; echo "1"; echo "STATE"; echo "r"; sleep 5; echo "w") | fdisk -w always -W always "${destination_device}"
elif [ "${distribution}" == "BlissOS" ]; then
	(echo "g"; echo "n"; echo "1"; echo ""; echo "+512M"; echo "t"; echo "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"; echo "x"; echo "n"; echo "EFI"; echo "r"; echo "n"; echo "2"; echo ""; echo "+$(( ${install_sizeMB} - 512 - 3 ))M"; echo "t"; echo "2"; echo "0FC63DAF-8483-4772-8E79-3D69D8477DE4"; echo "x"; echo "n"; echo "2"; echo "ROOT"; echo "r"; sleep 5; echo "w") | fdisk -w always -W always "${destination_device}"
else
	(echo "g"; echo "n"; echo "1"; echo ""; echo "+128M"; echo "t"; echo "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"; echo "x"; echo "n"; echo "EFI"; echo "r"; echo "n"; echo "2"; echo ""; echo "+896M"; echo "t"; echo "2"; echo "BC13C2FF-59E6-4262-A352-B275FD6F7172"; echo "x"; echo "n"; echo "2"; echo "BOOT"; echo "r"; echo "n"; echo "3"; echo ""; echo "+$(( ${root_sizeMB} - 3 ))M"; echo "t"; echo "3"; echo "0FC63DAF-8483-4772-8E79-3D69D8477DE4"; echo "x"; echo "n"; echo "3"; echo "ROOT"; echo "r"$(if [ ${#extra_partitions[@]} -ne 0 ]; then for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do echo -n "; echo \"n\"; echo \"$(( ${i} + 4 ))\"; echo \"\"; echo \"+$(( $(get_extra_partitions_attribute size ${i}) * 1024 ))M\"; echo \"t\"; echo \"$(( ${i} + 4 ))\"; echo \"0FC63DAF-8483-4772-8E79-3D69D8477DE4\"; echo \"x\"; echo \"n\"; echo \"$(( ${i} + 4 ))\"; echo \"$(echo $(get_extra_partitions_attribute name ${i}) | tr a-z A-Z)\"; echo \"r\""; done; fi); sleep 5; echo "w") | fdisk -w always -W always "${destination_device}"
fi
PARTITIONDEVICE
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/partition_script
}

generate_setup_and_mount_rootfs()
{
if [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/setup_and_mount_rootfs <<SETUPFILESYSTEMS
#!/bin/bash
set -e
if [ "${root_encryption}" == "Yes" ]; then
	echo -n '${encryption_password}' | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha256 --key-size 256 --pbkdf argon2id luksFormat "${root_partition}" -
	echo -n '${encryption_password}' | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha256 --key-size 256 luksOpen "${root_partition}" luks-"\$(blkid -s UUID -o value "${root_partition}")" -
	if [ "${root_fstype}" == "btrfs" ]; then
		mkfs.btrfs -K -L "${root_name}" /dev/mapper/luks-"\$(blkid -s UUID -o value "${root_partition}")"
		mount /dev/mapper/luks-"\$(blkid -s UUID -o value "${root_partition}")" /mnt
		btrfs subvolume create /mnt/@
		if [ -z "${separate_home}" ]; then btrfs subvolume create /mnt/@home; fi
		if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then btrfs subvolume create /mnt/@swap; fi
		umount /mnt
		mount -o "${final_root_mountoptions}" /dev/mapper/luks-"\$(blkid -s UUID -o value "${root_partition}")" /mnt
	else
		mkfs.ext4 -E nodiscard -F -L "${root_name}" /dev/mapper/luks-"\$(blkid -s UUID -o value "${root_partition}")"
		mount -o "${final_root_mountoptions}" /dev/mapper/luks-"\$(blkid -s UUID -o value "${root_partition}")" /mnt
	fi
	if [ "$(get_extra_partitions_attribute isencryptionused)" == "Yes" ]; then
		mkdir -p /mnt/root
		chmod 0750 /mnt/root
		dd bs=512 count=4 if=/dev/random of=/mnt/root/encryption.key iflag=fullblock
		chmod 0400 /mnt/root/encryption.key
		echo -n '${encryption_password}' | cryptsetup luksAddKey "${root_partition}" /mnt/root/encryption.key -
	fi
else
	if [ "${root_fstype}" == "btrfs" ]; then
		mkfs.btrfs -K -L "${root_name}" "${root_partition}"
		mount "${root_partition}" /mnt
		btrfs subvolume create /mnt/@
		if [ -z "${separate_home}" ]; then btrfs subvolume create /mnt/@home; fi
		if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then btrfs subvolume create /mnt/@swap; fi
		umount /mnt
		mount -o "${final_root_mountoptions}" "${root_partition}" /mnt
	else
		mkfs.ext4 -E nodiscard -F -L "${root_name}" "${root_partition}"
		mount -o "${final_root_mountoptions}" "${root_partition}" /mnt
	fi
fi
if [ "${root_fstype}" == "btrfs" ]; then
	if [ "${root_encryption}" == "Yes" ]; then
		if [ -z "${separate_home}" ]; then
			mkdir /mnt/home
			mount -o "${final_home_subvol_mountoptions}" /dev/mapper/luks-"\$(blkid -s UUID -o value "${root_partition}")" /mnt/home
		fi
		if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
			mkdir -p /mnt/var/swap
			mount -o "${final_swap_subvol_mountoptions}" /dev/mapper/luks-"\$(blkid -s UUID -o value "${root_partition}")" /mnt/var/swap
		fi
	else
		if [ -z "${separate_home}" ]; then
			mkdir /mnt/home
			mount -o "${final_home_subvol_mountoptions}" "${root_partition}" /mnt/home
		fi
		if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
			mkdir -p /mnt/var/swap
			mount -o "${final_swap_subvol_mountoptions}" "${root_partition}" /mnt/var/swap
		fi
	fi
fi
$(if [ ${#extra_partitions[@]} -ne 0 ]; then
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		cat <<MOUNTPARTITION
	if [ "$(get_extra_partitions_attribute encryption ${i})" == "Yes" ]; then
		echo -n '${encryption_password}' | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha256 --key-size 256 --pbkdf argon2id luksFormat "${partition_path}$(( ${i} + 4 ))" -
		echo -n '${encryption_password}' | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha256 --key-size 256 luksOpen "${partition_path}$(( ${i} + 4 ))" luks-"\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")" -
		if [ "${root_encryption}" == "Yes" ]; then echo -n '${encryption_password}' | cryptsetup luksAddKey "${partition_path}$(( ${i} + 4 ))" /mnt/root/encryption.key -; fi
		if [ "$(get_extra_partitions_attribute fstype ${i})" == "btrfs" ]; then
			mkfs.btrfs -K -L "$(get_extra_partitions_attribute name ${i})" /dev/mapper/luks-"\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")"
			mkdir -p /mnt$(get_extra_partitions_attribute mountpoint ${i})
			mount /dev/mapper/luks-"\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")" /mnt$(get_extra_partitions_attribute mountpoint ${i})
			btrfs subvolume create /mnt$(get_extra_partitions_attribute mountpoint ${i})/@$(echo $(get_extra_partitions_attribute mountpoint ${i}) | sed 's@/@@g')
			umount /mnt$(get_extra_partitions_attribute mountpoint ${i})
			mount -o "$(get_extra_partitions_attribute mountoptions ${i})" /dev/mapper/luks-"\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")" /mnt$(get_extra_partitions_attribute mountpoint ${i})
		else
			mkfs.ext4 -E nodiscard -F -L "$(get_extra_partitions_attribute name ${i})" /dev/mapper/luks-"\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")"
			mkdir -p /mnt$(get_extra_partitions_attribute mountpoint ${i})
			mount -o "$(get_extra_partitions_attribute mountoptions ${i})" /dev/mapper/luks-"\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")" /mnt$(get_extra_partitions_attribute mountpoint ${i})
		fi
	else
		if [ "$(get_extra_partitions_attribute fstype ${i})" == "btrfs" ]; then
			mkfs.btrfs -K -L "$(get_extra_partitions_attribute name ${i})" "${partition_path}$(( ${i} + 4 ))"
			mkdir -p /mnt$(get_extra_partitions_attribute mountpoint ${i})
			mount "${partition_path}$(( ${i} + 4 ))" /mnt$(get_extra_partitions_attribute mountpoint ${i})
			btrfs subvolume create /mnt$(get_extra_partitions_attribute mountpoint ${i})/@$(echo $(get_extra_partitions_attribute mountpoint ${i}) | sed 's@/@@g')
			umount /mnt$(get_extra_partitions_attribute mountpoint ${i})
			mount -o "$(get_extra_partitions_attribute mountoptions ${i})" "${partition_path}$(( ${i} + 4 ))" /mnt$(get_extra_partitions_attribute mountpoint ${i})
		else
			mkfs.ext4 -E nodiscard -F -L "$(get_extra_partitions_attribute name ${i})" "${partition_path}$(( ${i} + 4 ))"
			mkdir -p /mnt$(get_extra_partitions_attribute mountpoint ${i})
			mount -o "$(get_extra_partitions_attribute mountoptions ${i})" "${partition_path}$(( ${i} + 4 ))" /mnt$(get_extra_partitions_attribute mountpoint ${i})
		fi
	fi
MOUNTPARTITION
	done
fi)
SETUPFILESYSTEMS
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/setup_and_mount_rootfs
}

generate_mount_efi()
{
if [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/mount_efi <<SETUPFILESYSTEMS
#!/bin/bash
set -e
if [ "${distribution}" == "BlissOS" ]; then
	mkfs.fat -F 32 -n "EFI" "${efi_partition}"
	mkdir -p /mnt/boot/efi
	mount "${efi_partition}" /mnt/boot/efi
else
	mkfs.fat -F 32 -n "${efi_name}" "${efi_partition}"
	mkdir /mnt/boot
	if [ "${root_fstype}" == "btrfs" ]; then
		mkfs.btrfs -K -L "${boot_name}" "${boot_partition}"
		mount "${boot_partition}" /mnt/boot
		btrfs subvolume create /mnt/boot/@boot
		umount /mnt/boot
	else
		mkfs.ext4 -E nodiscard -F -L "${boot_name}" "${boot_partition}"
		if tune2fs -l "${boot_partition}" | grep "Filesystem features" | grep -q -w large_dir; then tune2fs -O ^large_dir "${boot_partition}"; fi
		if tune2fs -l "${boot_partition}" | grep "Filesystem features" | grep -q -w metadata_csum_seed; then tune2fs -O ^metadata_csum_seed "${boot_partition}"; fi
		if tune2fs -l "${boot_partition}" | grep "Filesystem features" | grep -q -w orphan_file; then tune2fs -O ^orphan_file "${boot_partition}"; fi
	fi
	if ([ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ]) && [ "${install_type}" == "image" ]; then
		losetup --show -fP "${boot_partition}" > /tmp/linuxloops/boot_loop
		mount -o "${final_boot_mountoptions}" \$(cat /tmp/linuxloops/boot_loop) /mnt/boot
		mkdir /mnt/boot/efi
		losetup --show -fP "${efi_partition}" > /tmp/linuxloops/efi_loop
		mount -o "${final_efi_mountoptions}" \$(cat /tmp/linuxloops/efi_loop) /mnt/boot/efi
	else
		mount -o "${final_boot_mountoptions}" "${boot_partition}" /mnt/boot
		mkdir /mnt/boot/efi
		mount -o "${final_efi_mountoptions}" "${efi_partition}" /mnt/boot/efi

	fi
fi
SETUPFILESYSTEMS
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/mount_efi
}

generare_enter_chroot()
{
if [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ] || [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/enter_chroot <<ENTERCHROOT
#!/bin/bash
set -e
if [ -d /mnt/etc/tmpfiles.d ]; then
	ln -s /dev/null /mnt/etc/tmpfiles.d/static-nodes-permissions.conf
	ln -s /dev/null /mnt/etc/tmpfiles.d/tpm-udev.conf
fi
if [ -d /mnt/etc/udev/rules.d ]; then
	ln -s /dev/null /mnt/etc/udev/rules.d/50-udev-default.rules
fi
if [ -d /mnt/etc/systemd/system ]; then
	ln -s /dev/null /mnt/etc/systemd/system/systemd-binfmt.service
	ln -s /dev/null /mnt/etc/systemd/system/systemd-resolved.service
	ln -s /dev/null /mnt/etc/systemd/system/systemd-tmpfiles-setup-dev.service
	ln -s /dev/null /mnt/etc/systemd/system/systemd-tmpfiles-setup-dev-early.service
fi
mount -t proc none /mnt/proc
mount --bind -o ro /mnt/proc/sys /mnt/proc/sys
mount --make-slave /mnt/proc/sys
mount --bind -o ro /sys /mnt/sys
mount --make-slave /mnt/sys
mount --bind /dev /mnt/dev
mount --make-slave /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --make-slave /mnt/dev/pts
mount -t tmpfs -o mode=1777 none /mnt/dev/shm
mount -t tmpfs none /mnt/run
mount -t tmpfs -o mode=1777 none /mnt/tmp
mkdir -p /mnt/tmp/linuxloops
mount --bind /tmp/linuxloops /mnt/tmp/linuxloops
mount --make-slave /mnt/tmp/linuxloops
if [ "${systemd_init}" == "Yes" ]; then
	if [ -d /mnt/sys/module/apparmor ]; then mkdir /tmp/apparmor; mount --bind /tmp/apparmor /mnt/sys/module/apparmor; fi
	mount --bind \$(tty) /mnt/dev/console
	mount --make-slave /mnt/dev/console
	touch /tmp/pid_ns
	sudo -b container=chroot unshare --pid=/tmp/pid_ns --fork --mount-proc --kill-child --root=/mnt /lib/systemd/systemd --unit=basic.target
	sleep 30
	nsenter --pid=/tmp/pid_ns unshare --mount-proc --root=/mnt bash -c "/lib/systemd/systemd-udevd --daemon"
	if [ "${distribution}" == "Ubuntu" ] || [ "${distribution}" == "Zorin" ]; then
		nsenter --pid=/tmp/pid_ns unshare --mount-proc --root=/mnt bash -c "echo exit 101 > /usr/sbin/policy-rc.d"
		nsenter --pid=/tmp/pid_ns unshare --mount-proc --root=/mnt bash -c "chmod +x /usr/sbin/policy-rc.d"
		nsenter --pid=/tmp/pid_ns unshare --mount-proc --root=/mnt bash -c "mkdir -p ${bootstrapdir}"
		nsenter --pid=/tmp/pid_ns unshare --mount-proc --root=/mnt bash -c "ln -s / ${bootstrapdir}/mnt"
	fi
	chroot_cmd="nsenter --pid=/tmp/pid_ns unshare --mount-proc --root=/mnt bash"
else
	chroot_cmd="chroot /mnt"
fi
if [ "${environment}" == "Enlightenment" ]; then
	dns_manager="connman/resolv.conf"
elif [ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "Elementary" ] || [ "${distribution}" == "Fedora" ] || [ "${distribution}" == "Fedora-Atomic" ] || [ "${distribution}" == "Linuxmint" ] || [ "${distribution}" == "Neon" ] || [ "${distribution}" == "Nobara" ] || [ "${distribution}" == "Pop" ] || [ "${distribution}" == "Qubes" ] || [ "${distribution}" == "Ubuntu" ] || [ "${distribution}" == "Zorin" ]; then
	dns_manager="systemd/resolve/stub-resolv.conf"
else
	dns_manager="NetworkManager/resolv.conf"
fi
rm -f /mnt/etc/resolv.conf
ln -s /run/"\${dns_manager}" /mnt/etc/resolv.conf
mkdir -p \$(dirname /mnt/run/"\${dns_manager}")
cp /etc/resolv.conf /mnt/run/"\${dns_manager}"
\${chroot_cmd} /tmp/linuxloops/chroot_init
if [ -f /tmp/linuxloops/install_desktop ]; then \${chroot_cmd} /tmp/linuxloops/install_desktop; fi
if [ -f /tmp/linuxloops/install_secureboot ]; then \${chroot_cmd} /tmp/linuxloops/install_secureboot; fi
if [ -f /tmp/linuxloops/install_custom_packages ]; then \${chroot_cmd} /tmp/linuxloops/install_custom_packages; fi
if [ -f /tmp/linuxloops/install_settings ]; then \${chroot_cmd} /tmp/linuxloops/install_settings; fi
if [ -f /tmp/linuxloops/install_user ]; then \${chroot_cmd} /tmp/linuxloops/install_user; fi
if [ -f /tmp/linuxloops/install_dmconfig ]; then \${chroot_cmd} /tmp/linuxloops/install_dmconfig; fi
if [ -f /tmp/linuxloops/install_live ]; then \${chroot_cmd} /tmp/linuxloops/install_live; fi
if [ -f /tmp/linuxloops/install_surface ]; then \${chroot_cmd} /tmp/linuxloops/install_surface; fi
if [ -f /tmp/linuxloops/install_nvidia ]; then \${chroot_cmd} /tmp/linuxloops/install_nvidia; fi
if [ -f /tmp/linuxloops/install_fstab ]; then \${chroot_cmd} /tmp/linuxloops/install_fstab; fi
if [ -f /tmp/linuxloops/install_swap ] && [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then /tmp/linuxloops/install_swap; fi
if [ -f /tmp/linuxloops/install_initramfs ]; then \${chroot_cmd} /tmp/linuxloops/install_initramfs; fi
if [ -f /tmp/linuxloops/install_bootloader ]; then \${chroot_cmd} /tmp/linuxloops/install_bootloader; fi
if [ -f /tmp/linuxloops/install_custom_script ]; then \${chroot_cmd} /tmp/linuxloops/install_custom_script; fi
if [ -f /tmp/linuxloops/cleanup ]; then \${chroot_cmd} /tmp/linuxloops/cleanup; fi
if [ -f /mnt/usr/sbin/policy-rc.d ]; then rm /mnt/usr/sbin/policy-rc.d; fi
if [ -L /mnt/etc/systemd/system/systemd-tmpfiles-setup-dev-early.service ]; then rm /mnt/etc/systemd/system/systemd-tmpfiles-setup-dev-early.service; fi
if [ -L /mnt/etc/systemd/system/systemd-tmpfiles-setup-dev.service ]; then rm /mnt/etc/systemd/system/systemd-tmpfiles-setup-dev.service; fi
if [ -L /mnt/etc/systemd/system/systemd-resolved.service ]; then rm /mnt/etc/systemd/system/systemd-resolved.service; fi
if [ -L /mnt/etc/systemd/system/systemd-binfmt.service ]; then rm /mnt/etc/systemd/system/systemd-binfmt.service; fi
if [ -L /mnt/etc/udev/rules.d/50-udev-default.rules ]; then rm /mnt/etc/udev/rules.d/50-udev-default.rules; fi
if [ -L /mnt/etc/tmpfiles.d/tpm-udev.conf ]; then rm /mnt/etc/tmpfiles.d/tpm-udev.conf; fi
if [ -L /mnt/etc/tmpfiles.d/static-nodes-permissions.conf ]; then rm /mnt/etc/tmpfiles.d/static-nodes-permissions.conf; fi
ENTERCHROOT
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/enter_chroot
}

generate_install_settings()
{
if [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ] || [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/install_settings <<APPLYSETTINGS
#!/bin/bash
set -e
if [ ! -f /etc/locale.gen ]; then echo "${locale}.UTF-8 UTF-8" > /etc/locale.gen; else sed -i 's@#${locale}.UTF-8 UTF-8\|# ${locale}.UTF-8 UTF-8@${locale}.UTF-8 UTF-8@g' /etc/locale.gen; fi
if [ ! "${distribution}" == "Bazzite" ] && [ ! "${distribution}" == "Fedora-Atomic" ]; then
	localedef -i ${locale} -f UTF-8 ${locale}.UTF-8
fi
echo "LANG=${locale}.UTF-8" > /etc/locale.conf
echo "LANG=${locale}.UTF-8" > /etc/default/locale
if [ -f /etc/default/console-setup ]; then sed -i 's@CHARMAP=.*@CHARMAP="UTF-8"@g' /etc/default/console-setup; fi
echo -e "KEYMAP=${keymap}" > /etc/vconsole.conf
cat >/etc/default/keyboard <<'DEBIANKEYBOARD'
XKBMODEL="pc105"
XKBLAYOUT="${keymap}"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
DEBIANKEYBOARD
mkdir -p /etc/X11/xorg.conf.d
cat >/etc/X11/xorg.conf.d/00-keyboard.conf <<'XKEYBOARD'
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "${keymap}"
EndSection
XKEYBOARD
ln -sf /usr/share/zoneinfo/"${timezone}" /etc/localtime
if [ "${distribution}" == "Gentoo" ] && [ "$(echo ${version} | cut -d '/' -f2)" == "Openrc" ]; then
	eselect locale set ${locale}.UTF-8
	echo -e 'keymap="${keymap}"\nextended_keymaps=""' > /etc/conf.d/keymaps
	echo -e '${timezone}' > /etc/timezone
elif [ "$(echo ${version} | cut -d '/' -f2)" == "Openrc" ]; then
	echo -e 'keymap="${keymap}"\nextended_keymaps=""' > /etc/conf.d/keymaps
	echo -e '${timezone}' > /etc/timezone
fi
if [ ! -f /etc/machine-id ] && [ ! -z "\$(command -v dbus-uuidgen)" ]; then dbus-uuidgen > /etc/machine-id; fi
mkdir -p /etc/network
echo -e "auto lo\niface lo inet loopback" > /etc/network/interfaces
echo "${hostname}" > /etc/hostname
if [ "${distribution}" == "Proxmox" ]; then
	echo -e "127.0.0.1 localhost localhost.localdomain\n\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\nff02::3 ip6-allhosts" > /etc/hosts
elif [ "${distribution}" == "Qubes" ]; then
	echo -e "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" > /etc/hosts
else
	echo -e "127.0.0.1 localhost localhost.localdomain\n127.0.1.1 ${hostname}\n\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\nff02::3 ip6-allhosts" > /etc/hosts
fi
if [ -d /etc/netplan ]; then echo -e 'network:\n    version: 2\n    renderer: NetworkManager\n    ethernets:\n        zz-all-en:\n            match:\n                name: "en*"\n            dhcp4: true\n        zz-all-eth:\n            match:\n                name: "eth*"\n            dhcp4: true' > /etc/netplan/01-netcfg.yaml; chmod 0600 /etc/netplan/01-netcfg.yaml; fi
if [ -d /etc/NetworkManager/conf.d ]; then echo -e '[connection]\nwifi.powersave = 2' > /etc/NetworkManager/conf.d/zz-wifi-powersave-disable.conf; fi
mkdir -p /etc/modprobe.d
echo 'blacklist pcspkr' > /etc/modprobe.d/pcspkr.conf
# Disable desktop icons for CLI programs
mkdir -p /etc/skel/.local/share/applications
for i in assistant assistant6-qttools-6 avahi-discover bssh bvnc cups designer gcr-prompter gcr-viewer linguist linguist6-qttools-6 mpv nm-connection-editor qdbusviewer qdbusviewer6-qttools-6 qv4l2 qvidcap; do echo -e '[Desktop Entry]\nType=Application\nVersion=1.0\nName=HideFromAppMenu\nNoDisplay=true' > /etc/skel/.local/share/applications/\$i.desktop; done
APPLYSETTINGS
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_settings
}

generate_install_secureboot()
{
if [ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Fedora-Atomic" ] || [ "${distribution}" == "Qubes" ] || [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/install_secureboot <<SECUREBOOT
#!/bin/bash
set -e
mkdir -p \${1}/etc/secureboot_key
if [ "${distribution}" == "AlmaLinux" ] || [ "${distribution}" == "RockyLinux" ]; then
	cp /usr/share/pki/sb-certs/secureboot-kernel-x86_64.cer \${1}/etc/secureboot_key/MOK.der
elif [ "${distribution}" == "OpenSUSE" ]; then
	cp /usr/share/efi/x86_64/grub.der \${1}/etc/secureboot_key/MOK.der
else
	openssl req -newkey rsa:4096 -nodes -keyout \${1}/etc/secureboot_key/MOK.key -new -x509 -sha256 -days 36500 -subj "/CN=Linuxloops Machine Owner Key/" -out \${1}/etc/secureboot_key/MOK.crt
	openssl x509 -outform DER -in \${1}/etc/secureboot_key/MOK.crt -out \${1}/etc/secureboot_key/MOK.der
	chmod 0640 \${1}/etc/secureboot_key/*
	cp \${1}/etc/secureboot_key/MOK.der \${1}/boot/efi/${distribution}.der
	if [ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ]; then
		exit 0
	elif [ "${distribution}" == "Fedora" ] || [ "${distribution}" == "Nobara" ]; then
		chown root:akmods /etc/secureboot_key/*
		mkdir -p /etc/pki/akmods/certs /etc/pki/akmods/private
		rm -rf /etc/pki/akmods/certs/public_key.der /etc/pki/akmods/private/private_key.priv
		ln -s /etc/secureboot_key/MOK.der /etc/pki/akmods/certs/public_key.der
		ln -s /etc/secureboot_key/MOK.key /etc/pki/akmods/private/private_key.priv
	elif [ "${distribution}" == "Debian" ] || [ "${distribution}" == "Devuan" ] || [ "${distribution}" == "Elementary" ] || [ "${distribution}" == "Kali" ] || [ "${distribution}" == "LMDE" ] || [ "${distribution}" == "Linuxmint" ] || [ "${distribution}" == "MX" ] || [ "${distribution}" == "Neon" ] || [ "${distribution}" == "Parrot" ] || [ "${distribution}" == "PikaOS" ] || [ "${distribution}" == "Pop" ] || [ "${distribution}" == "Ubuntu" ] || [ "${distribution}" == "Zorin" ]; then
		mkdir -p /var/lib/shim-signed/mok
		rm -rf /var/lib/shim-signed/mok/MOK.der /var/lib/shim-signed/mok/MOK.priv
		ln -s /etc/secureboot_key/MOK.der /var/lib/shim-signed/mok/MOK.der
		ln -s /etc/secureboot_key/MOK.key /var/lib/shim-signed/mok/MOK.priv
	fi
	mkdir -p /var/lib/dkms
	rm -rf /var/lib/dkms/mok.pub /var/lib/dkms/mok.key
	ln -s /etc/secureboot_key/MOK.der /var/lib/dkms/mok.pub
	ln -s /etc/secureboot_key/MOK.key /var/lib/dkms/mok.key
fi
SECUREBOOT
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_secureboot
}

generate_install_surface()
{
if [ ! "${surface}" == "Yes" ]; then return; fi
if [ "${distribution}" == "Debian" ] || [ "${distribution}" == "Elementary" ] || [ "${distribution}" == "Kali" ] || [ "${distribution}" == "Linuxmint" ] || [ "${distribution}" == "LMDE" ] || [ "${distribution}" == "MX" ] || [ "${distribution}" == "Neon" ] || [ "${distribution}" == "Proxmox" ] || [ "${distribution}" == "Ubuntu" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_surface <<SURFACEAPT
#!/bin/bash
set -e
curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/linux-surface/linux-surface/raw/refs/heads/master/pkg/keys/surface.asc | gpg --dearmor | dd of=/etc/apt/trusted.gpg.d/linux-surface.gpg
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" > /etc/apt/sources.list.d/linux-surface.list
apt update
if [ ! -z "${surface_remove}" ]; then DEBIAN_FRONTEND=noninteractive apt purge -y ${surface_remove}; fi
DEBIAN_FRONTEND=noninteractive apt install --purge -y linux-image-surface linux-headers-surface iptsd libwacom-surface surface-control surface-dtx-daemon git build-essential cmake meson ninja-build pkg-config libgnutls28-dev python3-pip python3-yaml python3-ply python3-jinja2 libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libtiff-dev qt6-base-dev qt6-tools-dev-tools libqt6opengl6-dev libinput-dev
curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/umlaeute/v4l2loopback/archive/v0.14.0.tar.gz | tar xz -C /usr/src
dkms add -m v4l2loopback -v 0.14.0
dkms install -m v4l2loopback -v 0.14.0 -k \$(ls /usr/lib/modules/*/modules.builtin | sed 's@/usr/lib/modules/@@g' | sed 's@/modules.builtin@@g')
git clone -b v0.5.0 https://git.libcamera.org/libcamera/libcamera.git /tmp/libcamera
cd /tmp/libcamera
sed -i "/'-Wshadow',/d" ./meson.build
meson setup build -Dpipelines=uvcvideo,vimc,ipu3 -Dipas=vimc,ipu3 -Dprefix=/usr -Dgstreamer=enabled -Dv4l2=true -Dbuildtype=release
ninja -C build
ninja -C build install
cd /
usermod -aG video '${useraccount_name}'
SURFACEAPT
elif [ "${distribution}" == "Pop" ] || [ "${distribution}" == "Zorin" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_surface <<SURFACEAPT
#!/bin/bash
set -e
curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/linux-surface/linux-surface/raw/refs/heads/master/pkg/keys/surface.asc | gpg --dearmor | dd of=/etc/apt/trusted.gpg.d/linux-surface.gpg
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" > /etc/apt/sources.list.d/linux-surface.list
apt update
DEBIAN_FRONTEND=noninteractive apt purge -y ${surface_remove}
DEBIAN_FRONTEND=noninteractive apt install --purge -y linux-image-surface linux-headers-surface iptsd libwacom-surface surface-control surface-dtx-daemon git build-essential cmake meson ninja-build pkg-config libgnutls28-dev python3-pip python3-yaml python3-ply python3-jinja2 qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 qttools5-dev-tools libtiff-dev libevent-dev gstreamer1.0-tools libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/umlaeute/v4l2loopback/archive/v0.13.2.tar.gz | tar xz -C /usr/src
dkms add -m v4l2loopback -v 0.13.2
dkms install -m v4l2loopback -v 0.13.2 -k \$(ls /usr/lib/modules/*/modules.builtin | sed 's@/usr/lib/modules/@@g' | sed 's@/modules.builtin@@g')
git clone -b v0.3.0 https://git.libcamera.org/libcamera/libcamera.git /tmp/libcamera
cd /tmp/libcamera
sed -i "s@-Wdeprecated-enum-enum-conversion@@g" ./meson.build
meson build -Dpipelines=uvcvideo,vimc,ipu3 -Dipas=vimc,ipu3 -Dprefix=/usr -Dgstreamer=enabled -Dv4l2=true -Dbuildtype=release
ninja -C build
ninja -C build install
cd /
usermod -aG video '${useraccount_name}'
SURFACEAPT
elif [ "${distribution}" == "Arch" ] || [ "${distribution}" == "CachyOS" ] || [ "${distribution}" == "KDE" ] || [ "${distribution}" == "Manjaro" ] || [ "${distribution}" == "SteamOS" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_surface <<SURFACEPACMAN
#!/bin/bash
set -e
curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/linux-surface/linux-surface/raw/refs/heads/master/pkg/keys/surface.asc | pacman-key --add -
pacman-key --finger 56C464BAAC421453
pacman-key --lsign-key 56C464BAAC421453
echo -e '[linux-surface]\nServer = https://pkg.surfacelinux.com/arch/' >> /etc/pacman.conf
pacman -Syu
if [ ! -z "${surface_remove}" ]; then pacman -Rsc --noconfirm ${surface_remove}; fi
pacman -S --noconfirm --needed linux-surface linux-surface-headers iptsd libcamera libcamera-tools gst-plugin-libcamera base-devel git fakeroot v4l2loopback-dkms
usermod -aG video '${useraccount_name}'
SURFACEPACMAN
elif [ "${distribution}" == "Fedora" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_surface <<SURFACEDNF
#!/bin/bash
set -e
dnf install -y 'dnf-command(versionlock)'
dnf versionlock add kernel\*
rm -rf /boot/.vmlinuz-* /boot/vmlinuz-* /boot/initramfs-* /boot/symvers-* /boot/System.map-* /usr/lib/modules/* /usr/src/kernels/*
dnf config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo
dnf update -y
dnf install -y --allowerasing kernel-surface kernel-surface-devel iptsd libwacom-surface surface-control surface-dtx-daemon libcamera libcamera-tools libcamera-qcam libcamera-gstreamer libcamera-ipa pipewire-plugin-libcamera akmod-v4l2loopback
usermod -aG video '${useraccount_name}'
SURFACEDNF
fi
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_surface
if [ ! -z "${kernel_parameters}" ]; then
	kernel_parameters="acpi_enforce_resources=lax ${kernel_parameters}"
else
	kernel_parameters="acpi_enforce_resources=lax"
fi
}

generate_install_nvidia()
{
if [ ! "${nvidia}" == "Yes" ] || [ "${distribution}" == "Bazzite" ]; then return; fi
if [ "${distribution}" == "Arch" ] || [ "${distribution}" == "Artix" ] || [ "${distribution}" == "CachyOS" ] || [ "${distribution}" == "KDE" ] || [ "${distribution}" == "Manjaro" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
pacman -S --noconfirm --needed nvidia-dkms libva-nvidia-driver
INSTALLNVIDIA
elif [ "${distribution}" == "Debian" ] || [ "${distribution}" == "Devuan" ] || [ "${distribution}" == "Kali" ] || [ "${distribution}" == "LMDE" ] || [ "${distribution}" == "MX" ] ||  [ "${distribution}" == "Proxmox" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
DEBIAN_FRONTEND=noninteractive apt install --purge -y nvidia-driver nvidia-vaapi-driver
INSTALLNVIDIA
elif [ "${distribution}" == "Elementary" ] || [ "${distribution}" == "Linuxmint" ] || [ "${distribution}" == "Neon" ] || [ "${distribution}" == "Ubuntu" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
DEBIAN_FRONTEND=noninteractive apt install --purge -y \$(apt search nvidia | grep nvidia-driver | grep -v '\-bin' | grep -v '\-open' | grep -v '\-server' | tail -1 | grep -o -P '(nvidia-driver-).*' | cut -d' ' -f1 | cut -d '/' -f1) nvidia-vaapi-driver
INSTALLNVIDIA
elif [ "${distribution}" == "Fedora" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
dnf install -y akmod-nvidia xorg-x11-drv-nvidia libva-nvidia-driver
INSTALLNVIDIA
elif [ "${distribution}" == "Fedora-Atomic" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
rpm-ostree -y install akmod-nvidia xorg-x11-drv-nvidia libva-nvidia-driver
INSTALLNVIDIA
elif [ "${distribution}" == "FoxFlake" ]; then
	foxflake_nvidia="
  # Nvidia open source driver support
  foxflake.nvidia.enable = true;

"
elif [ "${distribution}" == "GLF-OS" ]; then
	nixos_nvidia="
  services.xserver.videoDrivers = [ \"nvidia\" ];
  hardware.nvidia.open = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.nvidiaSettings = true;
"
elif [ "${distribution}" == "Gentoo" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
echo -e 'media-libs/nvidia-vaapi-driver ~amd64' > /etc/portage/package.accept_keywords/linuxloops
emerge -uN x11-drivers/nvidia-drivers media-libs/nvidia-vaapi-driver
INSTALLNVIDIA
elif [ "${distribution}" == "NixOS" ]; then
	nixos_nvidia="
services.xserver.videoDrivers = [ \"nvidia\" ];
hardware.nvidia.open = true;
hardware.nvidia.powerManagement.enable = true;
hardware.nvidia.nvidiaSettings = true;
"
elif [ "${distribution}" == "Nobara" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
dnf install -y nvidia-driver libva-nvidia-driver
INSTALLNVIDIA
elif [ "${distribution}" == "OpenSUSE" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
cat >/usr/lib/rpm/gnupg/keys/gpg-pubkey-db27fd5a-62589a51.asc <<NVIDIAREPOKEY
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.22 (GNU/Linux)

mQINBGJYmlEBEACKX1pzfrPA9WKY1gmoIGNGNOsUKETZQ4iWGCZ/jVuxXZzvXg1c
0xC/44ETenvxOor8kMpy8jJwy6IzIyNZniWWCOeNnITCark0eMY6w18eGqpgvGhL
iFo9y6ZdGOQoVqbyNritM1fQZnlCbPK11SBxkMmQ1eC+rLmD8xMslx/AS3/5Lu+2
GdA5H79p9CJoH/MpfsUH6NeojQkN/jqxG4VgHL488eMO120QSlDY53PuGqB5c/FN
yMQry8Hq+uapKLC1irZun/wfKSP2gIrIcXuS0TLjQeWKn+aX9xdZWZyVNsGUQ3aN
GnfHly14n+K9A+QjINtIt6PON7hHAd/aYNA/weR4IvDEwkU95JtNo37NpKHa0CHO
M+B31phcl9dLPfgDfLpCE04c87mpuSMTfCd8zneGWpHMFGIlW4o6dOsmoc/WwuJz
+U5BVdR483yQd4RMoq9AePtrRPPZCIG48i8oxltQgZqHL02+818hnOFyTml+ZSOr
swREOFa4OC8jYevZ+uu30xkf6/Jjt4cW/Woho62VOz1hQXGaoz8VXsWWnykb/cVr
aBhGLLIhV0WdRmhdh8R0bNC1FuyPtcvvFNA30hBc4OWVEMzJk1aPrbvmFIO6mw7m
93X1pUKYBE7ozEDQvbhItCO1+yDAdzNnrwGSvbuNTzs4Pn+qbldq1QngMQARAQAB
tDBOVklESUEgTGludXggRHJpdmVyIFRlYW0gPGxpbnV4LWJ1Z3NAbnZpZGlhLmNv
bT6JAjkEEwECACMFAmJYmlECGwMHCwkIBwMCAQYVCAIJCgsEFgIDAQIeAQIXgAAK
CRCx0NeI2yf9Wsn9D/9rbEFdcH5RfzhWx1DwaKAcmVSvRZf34w7R2DmES+y6I3lh
JIhc9A2eX+xMaZ1Zm3SQKt+RzyEwwReRYQ0FsEkfpr6tLHY7xt97e69NWH7/4yFN
aPIker/NSdyhOX/9ALmrMs82+I+t37KTCy9pHt31kIK0zCFmHT8g3Dl1gsSXhaWd
cUgpOuiMtcuUEhi6wkYHHIT7RSfHwq2apHVJKOvFI//fVVe01KOAVkdJW0kJFiNr
IBgrLHa3Y42dR9g5XnUINX4V/LUJnf66RLzC+OA/ps4gIl3UJ06dj9h8Dxgo9Md6
57+irheoIbcP+zSN6CaIGFHmmr+2I6ofP9Q9BtKZqNklfcISioWBamInYyyjyVuW
n47COZq8kgKLOS7yCmU8M+Y17W37pvjS9Q07lLxPBkbw6IlPc6MFZAynM13XCE9u
xzKrdFoT75wadAaY4Ox741u12jNYsdNbODrWmc8J4tw3z8whrWf4vSZveidboEav
OfFXxORrPHALB9Wegq9kJSYo68NYr/Dy0bvPeUKUpvJUX93YRVabQfmiTYAuSZIl
PMeQIHPQPh9QvNsZmOHSlOC9Tmncd4O1gqk4WDc2D95kIhzA8HQSSZTThM4Xe1Eh
Xks0dFlInjDFyMgAwsOaVDTWwjBfAaklUysV+CxhhEvSnuGx9h8Mi88K6g8heA==
=g062
-----END PGP PUBLIC KEY BLOCK-----
NVIDIAREPOKEY
rpm --import /usr/lib/rpm/gnupg/keys/gpg-pubkey-db27fd5a-62589a51.asc
zypper --non-interactive install openSUSE-repos-$(echo ${opensuse_version} | cut -d '/' -f1)-NVIDIA
zypper --non-interactive install --auto-agree-with-licenses --force-resolution nvidia-gl-G06 nvidia-video-G06
INSTALLNVIDIA
elif [ "${distribution}" == "Parrot" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
DEBIAN_FRONTEND=noninteractive apt install --purge -y -t $(echo ${parrot_version} | tr A-Z a-z)-backports nvidia-driver nvidia-vaapi-driver
INSTALLNVIDIA
elif [ "${distribution}" == "PikaOS" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
DEBIAN_FRONTEND=noninteractive apt install --purge -y pika-nvidia-driver nvidia-vaapi-driver
INSTALLNVIDIA
elif [ "${distribution}" == "Pop" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
DEBIAN_FRONTEND=noninteractive apt install --purge -y system76-driver-nvidia
INSTALLNVIDIA
elif [ "${distribution}" == "SteamOS" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
pacman -S --noconfirm --needed nvidia-open-dkms lib32-nvidia-utils libva-nvidia-driver
INSTALLNVIDIA
elif [ "${distribution}" == "Void" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
xbps-install -y nvidia nvidia-vaapi-driver
INSTALLNVIDIA
elif [ "${distribution}" == "Zorin" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
#!/bin/bash
set -e
DEBIAN_FRONTEND=noninteractive apt install --purge -y \$(apt search nvidia | grep nvidia-driver | grep -v '\-bin' | grep -v '\-open' | grep -v '\-server' | tail -1 | grep -o -P '(nvidia-driver-).*' | cut -d' ' -f1 | cut -d '/' -f1)
INSTALLNVIDIA
fi
if [ -f "${bootstrapdir}"/tmp/linuxloops/install_nvidia ]; then
	cat >>"${bootstrapdir}"/tmp/linuxloops/install_nvidia <<INSTALLNVIDIA
if [ -x /usr/lib/systemd/systemd ]; then
	if [ -f /usr/lib/systemd/system/nvidia-hibernate.service ]; then systemctl enable nvidia-hibernate.service; fi
	if [ -f /usr/lib/systemd/system/nvidia-resume.service ]; then systemctl enable nvidia-resume.service; fi
	if [ -f /usr/lib/systemd/system/nvidia-suspend.service ]; then systemctl enable nvidia-suspend.service; fi
	mkdir -p /etc/systemd/system-shutdown
	cat >/etc/systemd/system-shutdown/nvidia.shutdown <<'SHUTDOWNFIX'
#!/bin/sh
for MODULE in nvidia_drm nvidia_modeset nvidia_uvm nvidia; do
	if lsmod | grep "\$MODULE" &> /dev/null; then rmmod \$MODULE; fi
done
SHUTDOWNFIX
	chmod 0755 /etc/systemd/system-shutdown/nvidia.shutdown
fi
INSTALLNVIDIA
	chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_nvidia
fi
if [ ! -z "${kernel_parameters}" ]; then
	kernel_parameters="module_blacklist=nouveau nvidia-drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0 ibt=off ${kernel_parameters}"
else
	kernel_parameters="module_blacklist=nouveau nvidia-drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0 ibt=off"
fi
}

generate_install_fstab()
{
if [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Tails" ]; then return; fi
if [ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ]; then
	cat >"${bootstrapdir}"/tmp/linuxloops/install_fstab <<GENERATEFSTAB
#!/bin/bash
set -e
if [ "${root_encryption}" == "Yes" ]; then
	if [ "${root_fstype}" == "btrfs" ]; then
		fstab="
boot.initrd.luks.devices = {
	luks-\$(blkid -s UUID -o value "${root_partition}") = {
		device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}")\";
	};
};

fileSystems.\"/\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${root_partition}"))\";
	fsType = \"btrfs\";
	options = [ $(for i in $(echo ${final_root_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
		if [ -z "${separate_home}" ]; then
			fstab="\${fstab}

fileSystems.\"/home\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${root_partition}"))\";
	fsType = \"btrfs\";
	options = [ $(for i in $(echo ${final_home_subvol_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
		fi
		if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
			fstab="\${fstab}

fileSystems.\"/var/swap\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${root_partition}"))\";
	fsType = \"btrfs\";
	options = [ $(for i in $(echo ${final_swap_subvol_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
		fi
	else
		fstab="
boot.initrd.luks.devices = {
	luks-\$(blkid -s UUID -o value "${root_partition}") = {
		device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}")\";
	};
};

fileSystems.\"/\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${root_partition}"))\";
	fsType = \"ext4\";
	options = [ $(for i in $(echo ${final_root_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
	fi
else
	if [ "${root_fstype}" == "btrfs" ]; then
		fstab="
fileSystems.\"/\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}")\";
	fsType = \"btrfs\";
	options = [ $(for i in $(echo ${final_root_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
		if [ -z "${separate_home}" ]; then
			fstab="\${fstab}

fileSystems.\"/home\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}")\";
	fsType = \"btrfs\";
	options = [ $(for i in $(echo ${final_home_subvol_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
		fi
		if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
			fstab="\${fstab}

fileSystems.\"/var/swap\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}")\";
	fsType = \"btrfs\";
	options = [ $(for i in $(echo ${final_swap_subvol_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
		fi
	else
		fstab="
fileSystems.\"/\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}")\";
	fsType = \"ext4\";
	options = [ $(for i in $(echo ${final_root_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
	fi
fi
if [ "${root_fstype}" == "btrfs" ]; then
	fstab="\${fstab}

fileSystems.\"/boot\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${boot_partition}")\";
	fsType = \"btrfs\";
	options = [ $(for i in $(echo ${final_boot_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
else
	fstab="\${fstab}

fileSystems.\"/boot\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${boot_partition}")\";
	fsType = \"ext4\";
	options = [ $(for i in $(echo ${final_boot_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
fi
fstab="\${fstab}

fileSystems.\"/boot/efi\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${efi_partition}")\";
	fsType = \"vfat\";
	options = [ $(for i in $(echo ${final_efi_mountoptions} | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
fstab="\${fstab}

swapDevices =
[
  {
	device = \"/var/swap/swapfile\";
  }
];
"
fi
$(if [ ${#extra_partitions[@]} -ne 0 ]; then
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		if [ "$(get_extra_partitions_attribute encryption ${i})" == "Yes" ]; then
			cat <<FSTAB
			fstab="\${fstab}

fileSystems.\"$(get_extra_partitions_attribute mountpoint ${i})\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))"))\";
	fsType = \"$(get_extra_partitions_attribute fstype ${i})\";
	options = [ $(for i in $(echo $(get_extra_partitions_attribute mountoptions ${i}) | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
FSTAB
		else
			cat <<FSTAB
			fstab="\${fstab}

fileSystems.\"$(get_extra_partitions_attribute mountpoint ${i})\" = {
	device = \"/dev/disk/by-uuid/\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")\";
	fsType = \"$(get_extra_partitions_attribute fstype ${i})\";
	options = [ $(for i in $(echo $(get_extra_partitions_attribute mountoptions ${i}) | sed 's@,@ @g'); do echo -n "\\\"${i}\\\" "; done)];
};
"
FSTAB
		fi
	done
fi)
$(if [ ${#extra_partitions[@]} -ne 0 ]; then
			cat <<CRYPTTAB
			fstab="\${fstab}

environment.etc.crypttab.text = ''
CRYPTTAB
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		if [ "$(get_extra_partitions_attribute encryption ${i})" == "Yes" ]; then
			if [ "${root_encryption}" == "Yes" ]; then
				cat <<CRYPTTAB
luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") UUID=\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") /root/encryption.key luks
CRYPTTAB
			else
				cat <<CRYPTTAB
luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") UUID=\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") none luks
CRYPTTAB
			fi
		fi
	done
	cat <<CRYPTTAB
'';
"
CRYPTTAB
fi)
echo "\${fstab}" > /tmp/linuxloops/fstab
GENERATEFSTAB
else
	cat >"${bootstrapdir}"/tmp/linuxloops/install_fstab <<GENERATEFSTAB
#!/bin/bash
set -e
if [ "${live}" == "Yes" ]; then systemd_growfs_option=",x-systemd.growfs"; fi
rm -f /etc/fstab
touch /etc/fstab
chmod 0644 /etc/fstab
if [ "${root_encryption}" == "Yes" ]; then
	if [ "${root_fstype}" == "btrfs" ]; then
		echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${root_partition}")) / btrfs ${final_root_mountoptions}\${systemd_growfs_option} 0 0" >> /etc/fstab
		if [ -z "${separate_home}" ]; then echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${root_partition}")) /home btrfs ${final_home_subvol_mountoptions} 0 0" >> /etc/fstab; fi
		if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${root_partition}")) /var/swap btrfs ${final_swap_subvol_mountoptions} 0 0" >> /etc/fstab; fi
		echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${boot_partition}") /boot btrfs ${final_boot_mountoptions} 0 0" >> /etc/fstab
	else
		echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${root_partition}")) / ext4 ${final_root_mountoptions}\${systemd_growfs_option} 0 1" >> /etc/fstab
		echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${boot_partition}") /boot ext4 ${final_boot_mountoptions} 0 2" >> /etc/fstab
	fi
else
	if [ "${root_fstype}" == "btrfs" ]; then
		echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}") / btrfs ${final_root_mountoptions}\${systemd_growfs_option} 0 0" >> /etc/fstab
		if [ -z "${separate_home}" ]; then echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}") /home btrfs ${final_home_subvol_mountoptions} 0 0" >> /etc/fstab; fi
		if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}") /var/swap btrfs ${final_swap_subvol_mountoptions} 0 0" >> /etc/fstab; fi
		echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${boot_partition}") /boot btrfs ${final_boot_mountoptions} 0 0" >> /etc/fstab
	else
		echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}") / ext4 ${final_root_mountoptions}\${systemd_growfs_option} 0 1" >> /etc/fstab
		echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${boot_partition}") /boot ext4 ${final_boot_mountoptions} 0 2" >> /etc/fstab
	fi
fi
echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${efi_partition}") /boot/efi vfat ${final_efi_mountoptions} 0 2" >> /etc/fstab
if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then echo -e "/var/swap/swapfile none swap sw 0 0" >> /etc/fstab; fi
$(if [ ${#extra_partitions[@]} -ne 0 ]; then
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		if [ "$(get_extra_partitions_attribute encryption ${i})" == "Yes" ]; then
			if [ "$(get_extra_partitions_attribute fstype ${i})" == "btrfs" ]; then
				cat <<FSTAB
echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")) $(if ([ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "Fedora-Atomic" ]) && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home/*" ]] && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root/*" ]] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/var/*" ]]; then echo /var; fi)$(get_extra_partitions_attribute mountpoint ${i}) $(get_extra_partitions_attribute fstype ${i}) $(get_extra_partitions_attribute mountoptions ${i}) 0 0" >> /etc/fstab
FSTAB
			else
				cat <<FSTAB
echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")) $(if ([ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "Fedora-Atomic" ]) && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home/*" ]] && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root/*" ]] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/var/*" ]]; then echo /var; fi)$(get_extra_partitions_attribute mountpoint ${i}) $(get_extra_partitions_attribute fstype ${i}) $(get_extra_partitions_attribute mountoptions ${i}) 0 2" >> /etc/fstab
FSTAB
			fi
		else
			if [ "$(get_extra_partitions_attribute fstype ${i})" == "btrfs" ]; then
				cat <<FSTAB
echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") $(if ([ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "Fedora-Atomic" ]) && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home/*" ]] && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root/*" ]] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/var/*" ]]; then echo /var; fi)$(get_extra_partitions_attribute mountpoint ${i}) $(get_extra_partitions_attribute fstype ${i}) $(get_extra_partitions_attribute mountoptions ${i}) 0 0" >> /etc/fstab
FSTAB
			else
				cat <<FSTAB
echo -e "/dev/disk/by-uuid/\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") $(if ([ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "Fedora-Atomic" ]) && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home/*" ]] && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root/*" ]] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/var/*" ]]; then echo /var; fi)$(get_extra_partitions_attribute mountpoint ${i}) $(get_extra_partitions_attribute fstype ${i}) $(get_extra_partitions_attribute mountoptions ${i}) 0 2" >> /etc/fstab
FSTAB
			fi
		fi
	done
fi)
$(if [ ${#extra_partitions[@]} -ne 0 ]; then
	if [ "$(echo ${version} | cut -d '/' -f2)" == "Openrc" ]; then
		rm -f /etc/conf.d/dmcrypt
		touch /etc/conf.d/dmcrypt
		chmod 0644 /etc/conf.d/dmcrypt
		for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
			if [ "$(get_extra_partitions_attribute encryption ${i})" == "Yes" ]; then
				if [ "${root_encryption}" == "Yes" ]; then
					cat <<DMCRYPT
echo -e "target=luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")\nsource=UUID=\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")\nkey=/root/encryption.key\n" >> /etc/conf.d/dmcrypt
DMCRYPT
				else
					cat <<DMCRYPT
echo -e "target=luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")\nsource=UUID=\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")\n" >> /etc/conf.d/dmcrypt
DMCRYPT
				fi
			fi
		done
	else
		rm -f /etc/crypttab
		touch /etc/crypttab
		chmod 0644 /etc/crypttab
		for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
			if [ "$(get_extra_partitions_attribute encryption ${i})" == "Yes" ]; then
				if [ "${root_encryption}" == "Yes" ]; then
					cat <<CRYPTTAB
echo -e "luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") UUID=\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") /root/encryption.key luks" >> /etc/crypttab
CRYPTTAB
				else
					cat <<CRYPTTAB
echo -e "luks-\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") UUID=\$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))") none luks" >> /etc/crypttab
CRYPTTAB
				fi
			fi
		done
	fi
fi)
cat >/usr/sbin/linuxloops-btrfs-snapshot <<'LINUXLOOPS_BTRFS_SNAPSHOT'
#!/bin/bash

usage()
{
cat <<'USAGE'
linuxloops-btrfs-snapshot: btrfs system backup helper.
Usage: linuxloops-btrfs-snapshot --create|--restore
-c, --create		(Create a system backup)
-r, --restore		(Restore a system backup)
-h, --help		(Display this menu)
USAGE
}

create()
{
echo "Creating system backup."

if [ "\$(findmnt / -no SOURCE | cut -d '[' -f2 | cut -d ']' -f1)" == "/linuxloops-backup/@-backup" ] || [ "\$(findmnt /boot -no SOURCE | cut -d '[' -f2 | cut -d ']' -f1)" == "/linuxloops-backup/@boot-backup" ]; then
	echo "System backups cannot be created from the backup snapshot, restore the system backup and reboot first."
	exit 1
fi

if [ -d /boot/grub2 ]; then grub_version="2"; fi
cat /etc/grub.d/40_custom > /etc/grub.d/11_linuxloops_backup
echo "submenu 'Linuxloops backup' {" >> /etc/grub.d/11_linuxloops_backup
cat /boot/grub\${grub_version}/grub.cfg | sed -n '/^menuentry/,/^}/p' | sed 's#/@boot/#/linuxloops-backup/@boot-backup/#g' | sed 's#rootflags=subvol=@ #rootflags=subvol=linuxloops-backup/@-backup #g' >> /etc/grub.d/11_linuxloops_backup
echo "}" >> /etc/grub.d/11_linuxloops_backup
chmod 0755 /etc/grub.d/11_linuxloops_backup
grub\${grub_version}-mkconfig -o /boot/grub\${grub_version}/grub.cfg

subvolumes_dir="\$(mktemp -d /tmp/btrfs_backup.XXXXXXXX)"
mkdir "\${subvolumes_dir}"/{boot,root}
mount \$(findmnt /boot -no SOURCE | cut -d '[' -f1) -o subvol=/ "\${subvolumes_dir}"/boot
mount \$(findmnt / -no SOURCE | cut -d '[' -f1) -o subvol=/ "\${subvolumes_dir}"/root

mkdir -p "\${subvolumes_dir}"/boot/linuxloops-backup "\${subvolumes_dir}"/root/linuxloops-backup
if [ -d "\${subvolumes_dir}"/boot/linuxloops-backup/@boot-backup ]; then btrfs subvolume delete "\${subvolumes_dir}"/boot/linuxloops-backup/@boot-backup; fi
if [ -d "\${subvolumes_dir}"/root/linuxloops-backup/@-backup ]; then btrfs subvolume delete "\${subvolumes_dir}"/root/linuxloops-backup/@-backup; fi
btrfs subvolume snapshot "\${subvolumes_dir}"/boot/@boot "\${subvolumes_dir}"/boot/linuxloops-backup/@boot-backup
btrfs subvolume snapshot "\${subvolumes_dir}"/root/@ "\${subvolumes_dir}"/root/linuxloops-backup/@-backup
sed -i 's#subvol=@ #subvol=linuxloops-backup/@-backup #g' "\${subvolumes_dir}"/root/linuxloops-backup/@-backup/etc/fstab
sed -i 's#subvol=@boot #subvol=linuxloops-backup/@boot-backup #g' "\${subvolumes_dir}"/root/linuxloops-backup/@-backup/etc/fstab

umount "\${subvolumes_dir}"/root
umount "\${subvolumes_dir}"/boot

echo "System backup created."
}

restore()
{
echo "Restoring system backup."

subvolumes_dir="\$(mktemp -d /tmp/btrfs_backup.XXXXXXXX)"
mkdir "\${subvolumes_dir}"/{boot,root}
mount \$(findmnt /boot -no SOURCE | cut -d '[' -f1) -o subvol=/ "\${subvolumes_dir}"/boot
mount \$(findmnt / -no SOURCE | cut -d '[' -f1) -o subvol=/ "\${subvolumes_dir}"/root

if [ ! -d "\${subvolumes_dir}"/boot/linuxloops-backup/@boot-backup ] || [ ! -d "\${subvolumes_dir}"/root/linuxloops-backup/@-backup ]; then echo "No available snapshot to restore."; umount "\${subvolumes_dir}"/boot "\${subvolumes_dir}"/root; exit 1; fi

if [ -d "\${subvolumes_dir}"/boot/linuxloops-backup/@boot-replaced ]; then btrfs subvolume delete "\${subvolumes_dir}"/boot/linuxloops-backup/@boot-replaced; fi
if [ -d "\${subvolumes_dir}"/root/linuxloops-backup/@-replaced ]; then btrfs subvolume delete "\${subvolumes_dir}"/root/linuxloops-backup/@-replaced; fi
mv "\${subvolumes_dir}"/boot/@boot "\${subvolumes_dir}"/boot/linuxloops-backup/@boot-replaced
mv "\${subvolumes_dir}"/root/@ "\${subvolumes_dir}"/root/linuxloops-backup/@-replaced
btrfs subvolume snapshot "\${subvolumes_dir}"/boot/linuxloops-backup/@boot-backup "\${subvolumes_dir}"/boot/@boot
btrfs subvolume snapshot "\${subvolumes_dir}"/root/linuxloops-backup/@-backup "\${subvolumes_dir}"/root/@
sed -i 's#subvol=linuxloops-backup/@-backup #subvol=@ #g' "\${subvolumes_dir}"/root/@/etc/fstab
sed -i 's#subvol=linuxloops-backup/@boot-backup #subvol=@boot #g' "\${subvolumes_dir}"/root/@/etc/fstab

umount "\${subvolumes_dir}"/root
umount "\${subvolumes_dir}"/boot

echo "System backup restored, please reboot your computer."
}

if [[ \$EUID -ne 0 ]]; then echo "This script must be run as root."; exit 1; fi
if [ -z "\${1}" ] || [ ! -z "\${2}" ]; then usage; exit 1; fi

if [ -z "\$(command -v btrfs)" ] || [ -z "\$(findmnt / -no SOURCE | cut -d '[' -f1)" ] || ([ ! "\$(findmnt / -no SOURCE | cut -d '[' -f2 | cut -d ']' -f1)" == "/@" ] && [ ! "\$(findmnt / -no SOURCE | cut -d '[' -f2 | cut -d ']' -f1)" == "/linuxloops-backup/@-backup" ]) || [ -z "\$(findmnt /boot -no SOURCE | cut -d '[' -f1)" ] || ([ ! "\$(findmnt /boot -no SOURCE | cut -d '[' -f2 | cut -d ']' -f1)" == "/@boot" ] && [ ! "\$(findmnt /boot -no SOURCE | cut -d '[' -f2 | cut -d ']' -f1)" == "/linuxloops-backup/@boot-backup" ]); then
	echo "Conditions to run this script are not met."
	exit 1
fi

case "\${1}" in
	-c | --create)
		create
	;;
	-h | --help)
		usage
	;;
	-r | --restore)
		read -p "WARNING: Your root and boot partitions will be replaced by the backup ones, are you sure you want to continue ? (type yes to continue)"\$'\n' confirm
		if [ -z \${confirm} ] || [ ! \${confirm} == "yes" ]; then echo "Invalid answer \${confirm}, exiting"; exit 1; fi
		restore
	;;
	*)
		echo "\${1} argument is not valid"
		usage
		exit 1
	;;
esac

exit 0
LINUXLOOPS_BTRFS_SNAPSHOT
chmod 0755 /usr/sbin/linuxloops-btrfs-snapshot
GENERATEFSTAB
fi
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_fstab
}

add_linuxloops_pre()
{
touch "${bootstrapdir}"/tmp/linuxloops/install_initramfs
cat >>"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<'INITSCRIPT'
#!/bin/sh
export PATH=/sbin:/bin:/usr/sbin:/usr/bin
if [ -f /usr/local/etc/profile ]; then source /usr/local/etc/profile; fi

mkdir -p /dev /proc /sys /run
mount -n -t devtmpfs devtmpfs /dev  -o nosuid,mode=0755
mount -n -t proc     proc     /proc -o nosuid,noexec,nodev
mount -n -t sysfs    sysfs    /sys  -o nosuid,noexec,nodev
mount -n -t tmpfs    tmpfs    /run  -o nosuid,nodev,mode=0755

echo "linuxloops: boot sequence started." > /dev/kmsg
echo "linuxloops: img_uuid=$img_uuid" > /dev/kmsg
echo "linuxloops: img_path=$img_path" > /dev/kmsg

INITSCRIPT
}

add_linuxloops_recovery()
{
touch "${bootstrapdir}"/tmp/linuxloops/install_initramfs
cat >>"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<'INITSCRIPT'
recovery_shell()
{
	printk_levels="$(cat /proc/sys/kernel/printk)"
	echo 0 0 0 0 > /proc/sys/kernel/printk
	echo -e "\n\nYou are in the recovery shell, you can notably use the included tools to obtain data on your partitions ("blkid" or "lsblk") or to perform an fscheck ("e2fsck" or "ntfsfix").\nOnce you are done with your modifications, type \"exit\" to reboot the computer.\n\n"
	sh
	reboot -f
}

INITSCRIPT
}

add_linuxloops_udev_start()
{
touch "${bootstrapdir}"/tmp/linuxloops/install_initramfs
cat >>"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<'INITSCRIPT'
if [ -z "$img_uuid" ] || [ -z "$img_path" ]; then echo "linuxloops: invalid GRUB configuration." > /dev/kmsg; recovery_shell; fi

if [ -x /sbin/udevd ]; then
	UDEVD=/sbin/udevd
	UDEVD_BIN="udevd"
elif [ -x /lib/udev/udevd ]; then
	UDEVD=/lib/udev/udevd
	UDEVD_BIN="udevd"
elif [ -x /lib/systemd/systemd-udevd ]; then
	UDEVD=/lib/systemd/systemd-udevd
	UDEVD_BIN="systemd-udevd"
elif [ -x /usr/lib/systemd/systemd-udevd ]; then
	UDEVD=/usr/lib/systemd/systemd-udevd
	UDEVD_BIN="systemd-udevd"
elif [ -x /usr/lib64/systemd/systemd-udevd ]; then
	UDEVD=/usr/lib64/systemd/systemd-udevd
	UDEVD_BIN="systemd-udevd"
else
	echo "linuxloops: Cannot find udevd nor systemd-udevd." > /dev/kmsg
	recovery_shell
fi

$UDEVD --daemon --resolve-names=never >/linuxloops_udev.log 2>&1
udevadm trigger --action=add --type=subsystems
udevadm trigger --action=add --type=devices
udevadm settle

INITSCRIPT
}

add_linuxloops_main()
{
touch "${bootstrapdir}"/tmp/linuxloops/install_initramfs
cat >>"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<'INITSCRIPT'
if [ ! -z "$img_uuid" ] && [ ! -z "$img_path" ]; then
	if [ ! -b /dev/disk/by-partuuid/"$img_uuid" ]; then echo "linuxloops: Boot partition was not found." > /dev/kmsg; recovery_shell; fi
	mkdir /linuxloops_root || { echo "linuxloops: Root directory cannot be created." > /dev/kmsg; recovery_shell; }
	if [ ! -z "$linuxloops_debug" ]; then recovery_shell; fi

	fstype=$(blkid -s TYPE -o value /dev/disk/by-partuuid/"$img_uuid")
	if [ "$fstype" = "ntfs" ]; then
		ntfs-3g /dev/disk/by-partuuid/"$img_uuid" /linuxloops_root || { echo "linuxloops: The boot partition could not be mounted." > /dev/kmsg; recovery_shell; }
	else
		mount -n -t "$fstype" /dev/disk/by-partuuid/"$img_uuid" /linuxloops_root || { echo "linuxloops: The boot partition could not be mounted." > /dev/kmsg; recovery_shell; }
	fi

	if [ -f /linuxloops_root/"$img_path" ]; then
		modprobe loop || { echo "linuxloops: Loop module is not available." > /dev/kmsg; recovery_shell; }
		if [ ! -b /dev/loop0 ]; then mknod -m 660 /dev/loop0 b 7 0 || { echo "linuxloops: The loop device could not be created." > /dev/kmsg; recovery_shell; }; fi
		losetup --direct-io=off -P /dev/loop0 /linuxloops_root"$img_path" || { echo "linuxloops: The loop device could not be configured." > /dev/kmsg; recovery_shell; }
		#losetup -P /dev/loop0 /linuxloops_root"$img_path" || { echo "linuxloops: The loop device could not be configured." > /dev/kmsg; recovery_shell; }
	else
		echo "linuxloops: The rootfs image file was not found, it might be due to an incorrect GRUB config or unsupported configuration." > /dev/kmsg
		recovery_shell
	fi

	udevadm trigger --action=add --type=subsystems
	udevadm trigger --action=add --type=devices
	udevadm settle
fi

INITSCRIPT
}

add_linuxloops_udev_end()
{
touch "${bootstrapdir}"/tmp/linuxloops/install_initramfs
cat >>"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<'INITSCRIPT'
udevadm control --exit
udevadm info --cleanup-db

timer=0
while ps | grep -q '[u]devd'; do
	echo "linuxloops: udevd is not yet killed, sleeping 1s" > /dev/kmsg
	if [ $timer -eq 3 ]; then echo "linuxloops: udevd could not be killed, continuing anyway..." > /dev/kmsg; break; fi
	sleep 1
	timer=$((timer+1))
done

INITSCRIPT
}

add_linuxloops_post()
{
touch "${bootstrapdir}"/tmp/linuxloops/install_initramfs
cat >>"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<'INITSCRIPT'
if [ -z "$linuxloops_init" ]; then
	if [ -x /init ]; then
		linuxloops_init="/init"
	elif [ -x /sbin/init ]; then
		linuxloops_init="/sbin/init"
	else
		echo "linuxloops: No init system found." > /dev/kmsg
		recovery_shell
	fi
fi

echo "linuxloops: boot sequence finished." > /dev/kmsg

umount /run
umount /sys
umount /proc
umount /dev > /dev/null 2>&1 || umount -l /dev > /dev/null 2>&1 || echo "linuxloops: /dev was not properly unmounted" > /dev/kmsg

#sh

exec "$linuxloops_init"
INITSCRIPT
}

generate_initcpio()
{
cat >"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<INITCPIOSTART
#!/bin/bash
set -e
if [ "${distribution}" == "Artix" ] || [ "${distribution}" == "BlendOS" ] || [ "${distribution}" == "SteamOS" ] || [ "${environment}" == "None" ]; then
	if [ "${root_encryption}" == "Yes" ]; then
		sed -i 's@ block filesystems fsck)@ block encrypt filesystems fsck linuxloops)@g' /etc/mkinitcpio.conf
	else
		sed -i 's@ block filesystems fsck)@ block filesystems fsck linuxloops)@g' /etc/mkinitcpio.conf
	fi
else
	if [ "${root_encryption}" == "Yes" ]; then
		sed -i 's@ block filesystems fsck)@ block plymouth encrypt filesystems fsck linuxloops)@g' /etc/mkinitcpio.conf
	else
		sed -i 's@ block filesystems fsck)@ block plymouth filesystems fsck linuxloops)@g' /etc/mkinitcpio.conf
	fi
fi
rm -rf /boot/linuxloops
mkdir -p /boot/linuxloops/initcpio-hook
cat >/boot/linuxloops/initcpio-hook/linuxloops <<'INSTALLHOOK'
#!/bin/bash

build() {
	add_module "8250_dw"
	add_module "aes"
	add_module "atkbd"
	add_module "btrfs"
	add_module "cbc"
	add_module "dm_crypt"
	add_module "exfat"
	add_module "ext4"
	add_module "fuse"
	add_module "i8042"
	add_module "intel_lpss"
	add_module "intel_lpss_pci"
	add_module "loop"
	add_module "nvme"
	add_module "quota_v1"
	add_module "quota_v2"
	add_module "serio"
	add_module "sha256"
	add_module "surface_aggregator"
	add_module "surface_aggregator_registry"
	add_module "surface_hid"
	add_module "surface_hid_core"
	add_module "usbhid"
	add_module "xhci_pci"

	add_binary "bash"
	add_binary "blkid"
	add_binary "cryptsetup"
	add_binary "cut"
	add_binary "e2fsck"
	add_binary "find"
	add_binary "grep"
	add_binary "losetup"
	add_binary "lsblk"
	add_binary "ntfs-3g"
	add_binary "ntfsfix"
	add_binary "ps"
	add_binary "setfont"
	add_binary "setsid"

	cp "/boot/linuxloops/linuxloops" "\$BUILDROOT/linuxloops"

	for i in \$(find /usr/lib/udev/rules.d/*-linuxloops.rules 2>/dev/null); do
		cp "\${i}" "\$BUILDROOT\$i"
	done

	if ls /boot/vmlinuz-* >/dev/null 2>&1 && [ -f /etc/secureboot_key/MOK.key ] && [ -f /etc/secureboot_key/MOK.crt ] && [ ! -z "\$(command -v sbsign)" ] && [ ! -z "\$(command -v sbverify)" ]; then
		for i in /boot/vmlinuz-*; do
			if ! sbverify --list \$i | grep -q 'CN=Linuxloops Machine Owner Key'; then
				sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output \$i \$i
			fi
		done
	fi
}

help() {
    cat <<HELPEOF
Installs the linuxloops hook.
HELPEOF
}
INSTALLHOOK
chmod 0755 /boot/linuxloops/initcpio-hook/linuxloops
ln -s /boot/linuxloops/initcpio-hook/linuxloops /etc/initcpio/install/linuxloops
cat >/boot/linuxloops/linuxloops <<'LINUXLOOPSBINARY'
INITCPIOSTART
add_linuxloops_pre
add_linuxloops_recovery
add_linuxloops_udev_start
add_linuxloops_main
add_linuxloops_udev_end
add_linuxloops_post
echo -e "LINUXLOOPSBINARY" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "chmod 0755 /boot/linuxloops/linuxloops" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "(cd /boot/linuxloops && find . | cpio -o -H newc | gzip > /boot/linuxloops/linuxloops-recovery.img)" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
if [ "${distribution}" != "BlendOS" ]; then echo -e "mkinitcpio -P" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs; fi
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_initramfs
}

generate_initramfstools()
{
cat >"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<INITRAMFSTOOLSSTART
#!/bin/bash
set -e
rm -rf /boot/linuxloops
mkdir -p /boot/linuxloops/initramfstools-hook
cat >/boot/linuxloops/initramfstools-hook/linuxloops <<'INSTALLHOOK'
#!/bin/bash
PREREQ=""
prereqs()
{
   echo "\$PREREQ"
}

case \$1 in
prereqs)
   prereqs
   exit 0
   ;;
esac

. /usr/share/initramfs-tools/hook-functions
# Begin real processing below this line

	rm -f "\$DESTDIR/bin/losetup" "\$DESTDIR/sbin/losetup"

	manual_add_modules "8250_dw"
	manual_add_modules "aes"
	manual_add_modules "atkbd"
	manual_add_modules "btrfs"
	manual_add_modules "cbc"
	manual_add_modules "dm-crypt"
	manual_add_modules "exfat"
	manual_add_modules "ext4"
	manual_add_modules "fuse"
	manual_add_modules "i8042"
	manual_add_modules "intel_lpss"
	manual_add_modules "intel_lpss_pci"
	manual_add_modules "loop"
	manual_add_modules "nvme"
	manual_add_modules "quota_v1"
	manual_add_modules "quota_v2"
	manual_add_modules "serio"
	manual_add_modules "sha256"
	manual_add_modules "surface_aggregator"
	manual_add_modules "surface_aggregator_registry"
	manual_add_modules "surface_hid"
	manual_add_modules "surface_hid_core"
	manual_add_modules "usbhid"
	manual_add_modules "xhci_pci"

	copy_exec "\$(command -v bash)"
	copy_exec "\$(command -v blkid)"
	copy_exec "\$(command -v cryptsetup)"
	copy_exec "\$(command -v cut)"
	copy_exec "\$(command -v e2fsck)"
	copy_exec "\$(command -v find)"
	copy_exec "\$(command -v grep)"
	copy_exec "\$(command -v losetup)"
	copy_exec "\$(command -v lsblk)"
	copy_exec "\$(command -v ntfs-3g)"
	copy_exec "\$(command -v ntfsfix)"
	copy_exec "\$(command -v ps)"
	copy_exec "\$(command -v setfont)"
	copy_exec "\$(command -v setsid)"

	cp "/boot/linuxloops/linuxloops" "\$DESTDIR/linuxloops"

	for i in \$(find /usr/lib/udev/rules.d/*-linuxloops.rules 2>/dev/null); do
		cp "\${i}" "\$DESTDIR\$i"
	done

	if ls /boot/vmlinuz-* >/dev/null 2>&1 && [ -f /etc/secureboot_key/MOK.key ] && [ -f /etc/secureboot_key/MOK.crt ] && [ ! -z "\$(command -v sbsign)" ] && [ ! -z "\$(command -v sbverify)" ]; then
		for i in /boot/vmlinuz-*; do
			if ! sbverify --list \$i | grep -q 'CN=Linuxloops Machine Owner Key'; then
				sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output \$i \$i
			fi
		done
	fi
INSTALLHOOK
chmod 0755 /boot/linuxloops/initramfstools-hook/linuxloops
ln -s /boot/linuxloops/initramfstools-hook/linuxloops /etc/initramfs-tools/hooks/linuxloops
cat >/boot/linuxloops/linuxloops <<'LINUXLOOPSBINARY'
INITRAMFSTOOLSSTART
add_linuxloops_pre
add_linuxloops_recovery
add_linuxloops_udev_start
add_linuxloops_main
add_linuxloops_udev_end
add_linuxloops_post
echo -e "LINUXLOOPSBINARY" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "chmod 0755 /boot/linuxloops/linuxloops" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "(cd /boot/linuxloops && find . | cpio -o -H newc | gzip > /boot/linuxloops/linuxloops-recovery.img)" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "DEBIAN_FRONTEND=noninteractive dpkg-reconfigure keyboard-configuration" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "DEBIAN_FRONTEND=noninteractive dpkg-reconfigure console-setup" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "update-initramfs -u -k all" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_initramfs
}

generate_dracut()
{
cat >"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<INITDRACUTSTART
#!/bin/bash
set -e
rm -rf /boot/linuxloops
mkdir -p /boot/linuxloops/dracut-hook
cat >/boot/linuxloops/dracut-hook/module-setup.sh <<'INSTALLHOOK'
#!/bin/bash

check() {
	return 0
}

installkernel() {
	instmods "8250_dw"
	instmods "aes"
	instmods "atkbd"
	instmods "btrfs"
	instmods "cbc"
	instmods "dm-crypt"
	instmods "exfat"
	instmods "ext4"
	instmods "fuse"
	instmods "i8042"
	instmods "intel_lpss"
	instmods "intel_lpss_pci"
	instmods "loop"
	instmods "nvme"
	instmods "quota_v1"
	instmods "quota_v2"
	instmods "serio"
	instmods "sha256"
	instmods "surface_aggregator"
	instmods "surface_aggregator_registry"
	instmods "surface_hid"
	instmods "surface_hid_core"
	instmods "usbhid"
	instmods "xhci_pci"
}

install() {
	inst "\$(command -v bash)" "/usr/bin/bash"
	inst "\$(command -v blkid)" "/usr/sbin/blkid"
	inst "\$(command -v cryptsetup)" "/usr/sbin/cryptsetup"
	inst "\$(command -v cut)" "/usr/sbin/cut"
	inst "\$(command -v e2fsck)" "/usr/sbin/e2fsck"
	inst "\$(command -v find)" "/usr/bin/find"
	inst "\$(command -v grep)" "/usr/sbin/grep"
	inst "\$(command -v losetup)" "/usr/sbin/losetup"
	inst "\$(command -v lsblk)" "/usr/sbin/lsblk"
	inst "\$(command -v ntfs-3g)" "/usr/sbin/ntfs-3g"
	inst "\$(command -v ntfsfix)" "/usr/sbin/ntfsfix"
	inst "\$(command -v ps)" "/usr/bin/ps"
	inst "\$(command -v setfont)" "/usr/bin/setfont"
	inst "\$(command -v setsid)" "/usr/sbin/setsid"

	cp "/boot/linuxloops/linuxloops" "\${initdir}/linuxloops"
	
	for i in \$(find /usr/lib/udev/rules.d/*-linuxloops.rules 2>/dev/null); do
		cp "\${i}" "\${initdir}\$i"
	done

	if ls /boot/vmlinuz-* >/dev/null 2>&1 && [ -f /etc/secureboot_key/MOK.key ] && [ -f /etc/secureboot_key/MOK.crt ] && [ ! -z "\$(command -v sbsign)" ] && [ ! -z "\$(command -v sbverify)" ]; then
		for i in /boot/vmlinuz-*; do
			if ! sbverify --list \$i | grep -q 'CN=Linuxloops Machine Owner Key'; then
				sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output \$i \$i
			fi
		done
	fi
}
INSTALLHOOK
chmod 0755 /boot/linuxloops/dracut-hook/module-setup.sh
mkdir -p /usr/lib/dracut/modules.d/99linuxloops
ln -s /boot/linuxloops/dracut-hook/module-setup.sh /usr/lib/dracut/modules.d/99linuxloops/module-setup.sh
cat >/boot/linuxloops/linuxloops <<'LINUXLOOPSBINARY'
INITDRACUTSTART
add_linuxloops_pre
add_linuxloops_recovery
add_linuxloops_udev_start
add_linuxloops_main
add_linuxloops_udev_end
add_linuxloops_post
echo -e "LINUXLOOPSBINARY" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "chmod 0755 /boot/linuxloops/linuxloops" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "(cd /boot/linuxloops && find . | cpio -o -H newc | gzip > /boot/linuxloops/linuxloops-recovery.img)" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "mkdir -p /etc/dracut.conf.d" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "echo 'hostonly=\"no\"' > /etc/dracut.conf.d/99-linuxloops.conf" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
echo -e "dracut --regenerate-all --force" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_initramfs
}

generate_nixos_config()
{
cmdline="systemd.log_target=null quiet"
if [ ! -z "${kernel_parameters}" ]; then cmdline="${cmdline} ${kernel_parameters}"; fi
cat >"${bootstrapdir}"/tmp/linuxloops/install_initramfs <<INITNIXOS
#!/bin/bash
set -e
cmdline="${cmdline}"
if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
	if [ "${root_fstype}" == "btrfs" ]; then
		if [ "${root_encryption}" == "Yes" ]; then
			if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} resume=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) resume_offset=\$(btrfs inspect-internal map-swapfile -r /mnt/var/swap/swapfile)"; else cmdline="resume=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) resume_offset=\$(btrfs inspect-internal map-swapfile -r /mnt/var/swap/swapfile)"; fi
		else
			if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} resume=UUID=\$(blkid -s UUID -o value ${root_partition}) resume_offset=\$(btrfs inspect-internal map-swapfile -r /mnt/var/swap/swapfile)"; else cmdline="resume=UUID=\$(blkid -s UUID -o value ${root_partition}) resume_offset=\$(btrfs inspect-internal map-swapfile -r /mnt/var/swap/swapfile)"; fi
		fi
	else
		if [ "${root_encryption}" == "Yes" ]; then
			if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} resume=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) resume_offset=\$(filefrag -v /mnt/var/swap/swapfile | head -4 | tail -1 | tr -s ' ' | cut -d' ' -f5 | cut -d'.' -f1)"; else cmdline="resume=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) resume_offset=\$(filefrag -v /mnt/var/swap/swapfile | head -4 | tail -1 | tr -s ' ' | cut -d' ' -f5 | cut -d'.' -f1)"; fi
		else
			if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} resume=UUID=\$(blkid -s UUID -o value ${root_partition}) resume_offset=\$(filefrag -v /mnt/var/swap/swapfile | head -4 | tail -1 | tr -s ' ' | cut -d' ' -f5 | cut -d'.' -f1)"; else cmdline="resume=UUID=\$(blkid -s UUID -o value ${root_partition}) resume_offset=\$(filefrag -v /mnt/var/swap/swapfile | head -4 | tail -1 | tr -s ' ' | cut -d' ' -f5 | cut -d'.' -f1)"; fi
		fi
	fi
fi
cmdline=\$(echo -n "\"\${cmdline}\"" | sed 's@ @" "@g')
mkdir -p /mnt/etc/nixos
if [ "${distribution}" == "FoxFlake" ]; then
curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/sebanc/foxflake/raw/refs/heads/$(echo ${foxflake_version} | tr A-Z a-z)/installer/target-configuration/flake.nix -o /mnt/etc/nixos/flake.nix
case "$(echo ${environment} | cut -d'/' -f2)" in
	'Minimal')
		bundles=' '
	;;
	'Standard')
		bundles='"standard"'
	;;
	'Gaming')
		bundles='"gaming"'
	;;
	'Studio')
		bundles='"studio"'
	;;
	'Standard+Gaming')
		bundles='"standard" "gaming"'
	;;
	'Standard+Studio')
		bundles='"standard" "studio"'
	;;
	'Gaming+Studio')
		bundles='"gaming" "studio"'
	;;
	'Full')
		bundles='"standard" "gaming" "studio"'
	;;
esac
	cat >/mnt/etc/nixos/configuration.nix <<NIXOSCONFIGURATION
{ pkgs, lib, ... }:

{
  # Imports
  imports =
    [
      ./hardware-configuration.nix
      ./linuxloops.nix
    ];

  # Desktop environment type
  foxflake.environment.type = "$(echo ${environment} | cut -d'/' -f1 | tr A-Z a-z)";

${autologin_commands}

  # Bundles, system packages, flatpaks and waydroid configuration
  foxflake.system.bundles = [ \${bundles} ];         # e.g.: "standard" and/or "gaming" and/or "studio"
  foxflake.system.packages = with pkgs; [ ];         # e.g.: with pkgs; [ firefox ]
  foxflake.system.flatpaks = [ ];                    # e.g.: [ "org.mozilla.firefox" ];
  foxflake.system.waydroid = true;

  # User configuration (including user packages and flatpaks)
  foxflake.users.${useraccount_name}.extraGroups = [ "wheel" "networkmanager" ];
  foxflake.users.${useraccount_name}.packages = with pkgs; [ ];         # e.g.: with pkgs; [ firefox ]
  foxflake.users.${useraccount_name}.flatpaks = [ ];                    # e.g.: [ "org.mozilla.firefox" ];

${foxflake_nvidia}

  # Keyboard configuration
  foxflake.internationalisation.keyboard.layout = "${keymap}";
  foxflake.internationalisation.keyboard.variant = "";
  foxflake.internationalisation.keyboard.consoleKeymap = "${keymap}";

  # Locale configuration
  foxflake.internationalisation.defaultLocale = "${locale}.UTF-8";

  # Timezone configuration
  foxflake.internationalisation.timezone = "${timezone}";

  # Initially installed version (DO NOT TOUCH)
  foxflake.stateVersion = "24.11";
}
NIXOSCONFIGURATION
elif [ "${distribution}" == "GLF-OS" ]; then
	curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/Gaming-Linux-FR/GLF-OS/raw/refs/heads/$(echo ${glfos_version} | tr A-Z a-z)/iso-cfg/flake.nix -o /mnt/etc/nixos/flake.nix
	mkdir /mnt/etc/nixos/customConfig
	curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/Gaming-Linux-FR/GLF-OS/raw/refs/heads/$(echo ${glfos_version} | tr A-Z a-z)/iso-cfg/customConfig/default.nix -o /mnt/etc/nixos/customConfig/default.nix
	cat >/mnt/etc/nixos/configuration.nix <<NIXOSCONFIGURATION
{ pkgs, lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [
    ./hardware-configuration.nix
    ./linuxloops.nix
    ./customConfig
  ];

  glf.nvidia_config.enable = false;
  glf.standBy.enable = false;

  users.users.${useraccount_name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "scanner" "lp" "disk" ];
  };

  boot.kernelParams = [ \${cmdline} ];

  console.earlySetup = true;
  console.keyMap = "${keymap}";
  i18n.defaultLocale = "${locale}.UTF-8";
  time.timeZone = "${timezone}";

  services.thermald.enable = true;

  services.xserver = {
    xkb.layout = "${keymap}";
    xkb.variant = "";
  };

  networking.hostName = "${hostname}";
  networking.networkmanager.enable = true;

${autologin_commands}

${nixos_nvidia}

  system.stateVersion = "24.11"; # DO NOT TOUCH
}
NIXOSCONFIGURATION
else
	cat >/mnt/etc/nixos/configuration.nix <<NIXOSCONFIGURATION
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
imports = [
  ./hardware-configuration.nix
  ./linuxloops.nix
];

boot.kernelPackages = pkgs.linuxPackages;
boot.kernelParams = [ \${cmdline} ];
boot.plymouth.enable = true;

users.users.${useraccount_name} = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
};

console.earlySetup = true;
console.keyMap = "${keymap}";
i18n.defaultLocale = "${locale}.UTF-8";
time.timeZone = "${timezone}";

hardware.bluetooth.enable = true;
hardware.sensor.iio.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
};
services.pulseaudio.enable = false;
services.thermald.enable = true;

networking.hostName = "${hostname}";
networking.networkmanager.enable = true;

hardware.sane.enable = true;
services.avahi.enable = true;
services.avahi.nssmdns4 = true;
services.printing.enable = true;

environment.systemPackages = with pkgs; [ firefox ffmpeg ${custom_packages} ];
$(if echo "${custom_packages}" | grep -wq 'steam'; then echo -e 'programs.steam = {\n  enable = true;\n  remotePlay.openFirewall = true;\n  dedicatedServer.openFirewall = true;\n  localNetworkGameTransfers.openFirewall = true;\n};'; fi)

${nixos_desktop}

hardware.graphics.enable = true;
hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];
$(if echo "${custom_packages}" | grep -wq 'steam\|wine'; then echo -e 'hardware.graphics.enable32Bit = true;'; fi)
${nixos_nvidia}

$(cat "${custom_script}" 2>/dev/null)

nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};
nix.settings.auto-optimise-store = true;
nixpkgs.config.allowUnfree = true;

systemd.services."getty@tty1".enable = false;
systemd.services."autovt@tty1".enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
system.stateVersion = "24.11"; # Did you read the comment?
}
NIXOSCONFIGURATION
fi
cat >/mnt/etc/nixos/shim-signed.nix <<'NIXOSSHIM'
{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  pname = "shim-signed";
  version = "15.8";
  src = pkgs.fetchurl {
    url = "http://archive.ubuntu.com/ubuntu/pool/main/s/shim-signed/shim-signed_1.59+15.8-0ubuntu2_amd64.deb";
    sha256 = "f8ed71ce2d91a304b6d5eb84997f846f331b554578bc02dbfe78e13ad8ac81a9";
  };
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x \$src shim-signed
    runHook postUnpack
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p "\$out/share"
    cp -r shim-signed/usr/lib/shim "\$out/share/"
    runHook postInstall
  '';
  nativeBuildInputs = with pkgs; [ dpkg ];
}
NIXOSSHIM
echo -e '# This file contains the fstab configuration.\n{ config, lib, pkgs, ... }:\n\n{' > /mnt/etc/nixos/hardware-configuration.nix
cat /tmp/linuxloops/fstab >>/mnt/etc/nixos/hardware-configuration.nix
echo -e "}" >> /mnt/etc/nixos/hardware-configuration.nix
cat >/mnt/etc/nixos/linuxloops.nix <<'NIXOSLINUXLOOPS'
# Do not modify this file which contains the linuxloops configuration.
# Please make changes to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
nixpkgs.overlays = [ (final: prev: { shim-signed = prev.callPackage ./shim-signed.nix {}; }) ];
environment.systemPackages = with pkgs; [ ntfs3g openssl sbsigntool shim-signed ];
boot.consoleLogLevel = 3;
hardware.cpu.intel.updateMicrocode = true;
hardware.cpu.amd.updateMicrocode = true;
hardware.enableAllFirmware = true;
services.logrotate.checkConfig = false;

$(if [ "${install_type}" == "image" ]; then echo -e "boot.kernelParams = [ \"\\\${linuxloops_args}\" ];\n"; fi)
boot.loader.efi.canTouchEfiVariables = false;
boot.loader.efi.efiSysMountPoint = "/boot/efi";
boot.loader.grub.configurationLimit = 5;
boot.loader.grub.device = "nodev";
boot.loader.grub.efiInstallAsRemovable = true;
boot.loader.grub.efiSupport = true;
boot.loader.grub.enable = true;
boot.loader.grub.extraInstallCommands = ''	
  \${pkgs.coreutils}/bin/cat >/tmp/sbat.csv <<GRUBSBAT
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
grub,3,Free Software Foundation,grub,2:\$(\${pkgs.grub2_efi}/bin/grub-install -V | \${pkgs.coreutils}/bin/cut -d' ' -f3),https//www.gnu.org/software/grub/
grub.$(echo ${distribution} | tr [:upper:] [:lower:]),1,${distribution} Linux,grub,2:\$(\${pkgs.grub2_efi}/bin/grub-install -V | \${pkgs.coreutils}/bin/cut -d' ' -f3),https//www.gnu.org/software/grub/
GRUBSBAT
  \${pkgs.coreutils}/bin/rm -rf /boot/efi/EFI/BOOT /boot/efi/EFI/${bootloader_id}
  \${pkgs.grub2_efi}/bin/grub-install --target=x86_64-efi --efi-directory=/boot/efi --no-nvram --bootloader-id="${bootloader_id}" --sbat=/tmp/sbat.csv --modules="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs zfs zfscrypt zfsinfo"
  \${pkgs.grub2_efi}/bin/grub-install --target=x86_64-efi --efi-directory=/boot/efi --no-nvram --removable --sbat=/tmp/sbat.csv --modules="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs zfs zfscrypt zfsinfo"
  if [ -f \${pkgs.shim-signed}/share/shim/shimx64.efi.signed.latest ] && [ -f \${pkgs.shim-signed}/share/shim/mmx64.efi ]; then
    \${pkgs.coreutils}/bin/mv /boot/efi/EFI/BOOT/BOOTX64.EFI /boot/efi/EFI/BOOT/grubx64.efi
    \${pkgs.coreutils}/bin/cp \${pkgs.shim-signed}/share/shim/shimx64.efi.signed.latest /boot/efi/EFI/BOOT/BOOTX64.EFI
    \${pkgs.coreutils}/bin/cp \${pkgs.shim-signed}/share/shim/shimx64.efi.signed.latest /boot/efi/EFI/${bootloader_id}/shimx64.efi
    \${pkgs.coreutils}/bin/cp \${pkgs.shim-signed}/share/shim/mmx64.efi /boot/efi/EFI/BOOT/mmx64.efi
    \${pkgs.coreutils}/bin/cp \${pkgs.shim-signed}/share/shim/mmx64.efi /boot/efi/EFI/${bootloader_id}/mmx64.efi
    if [ -x \${pkgs.sbsigntool}/bin/sbverify ] && [ -x \${pkgs.sbsigntool}/bin/sbattach ] && [ -x \${pkgs.sbsigntool}/bin/sbsign ] && [ -f /etc/secureboot_key/MOK.key ] && [ -f /etc/secureboot_key/MOK.crt ]; then
      for grubefi in \$(\${pkgs.findutils}/bin/find /boot/efi/EFI/BOOT/grubx64.efi) \$(\${pkgs.findutils}/bin/find /boot/efi/EFI/"${bootloader_id}"/grubx64.efi); do
        for sig in \$(\${pkgs.sbsigntool}/bin/sbverify --list "\$grubefi" | \${pkgs.gnugrep}/bin/grep '^signature' | \${pkgs.gnused}/bin/sed 's@signature @@g' | \${pkgs.coreutils}/bin/sort -r); do \${pkgs.sbsigntool}/bin/sbattach --signum "\$sig" --remove "\$grubefi"; done
        \${pkgs.sbsigntool}/bin/sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output "\$grubefi" "\$grubefi"
      done
    fi
  fi
  if \${pkgs.coreutils}/bin/ls /boot/kernels/*-linux-*Image >/dev/null 2>&1 && [ -f /etc/secureboot_key/MOK.key ] && [ -f /etc/secureboot_key/MOK.crt ] && [ -x \${pkgs.sbsigntool}/bin/sbsign ] && [ -x \${pkgs.sbsigntool}/bin/sbverify ]; then
    for i in /boot/kernels/*-linux-*Image; do
      if ! \${pkgs.sbsigntool}/bin/sbverify --list \$i | \${pkgs.gnugrep}/bin/grep -q 'CN=Linuxloops Machine Owner Key'; then
        \${pkgs.sbsigntool}/bin/sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output \$i \$i
      fi
    done
  fi
'';
boot.loader.grub.fsIdentifier = "uuid";
boot.loader.grub.splashImage = lib.mkForce null;
boot.loader.grub.theme = lib.mkForce null;
boot.loader.grub.timeoutStyle = $(if [ ! -z "${grub_hide}" ] && [ "${grub_hide}" == "Yes" ]; then echo "\"hidden\""; else echo "\"menu\""; fi);
boot.loader.grub.useOSProber = false;
boot.loader.timeout = $(if [ ! -z "${grub_hide}" ] && [ "${grub_hide}" == "Yes" ]; then echo 2; else echo 5; fi);

#https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/all-hardware.nix
boot.initrd.availableKernelModules = [ "3w-9xxx" "3w-xxxx" "8250_dw" "aes" "ahci" "aic79xx" "aic7xxx" "arcmsr" "ata_piix" "atkbd" "btrfs" "cbc" "dm_crypt" "ehci_hcd" "encrypted_keys" "exfat" "ext4" "fuse" "hv_storvsc" "i8042" "intel_lpss" "intel_lpss_pci" "loop" "mmc_block" "mptspi" "nvme" "ohci1394" "pata_ali" "pata_amd" "pata_artop" "pata_atiixp" "pata_efar" "pata_hpt366" "pata_hpt37x" "pata_hpt3x2n" "pata_hpt3x3" "pata_it8213" "pata_it821x" "pata_jmicron" "pata_marvell" "pata_mpiix" "pata_netcell" "pata_ns87410" "pata_oldpiix" "pata_pcmcia" "pata_pdc2027x" "pata_qdi" "pata_rz1000" "pata_serverworks" "pata_sil680" "pata_sis" "pata_sl82c105" "pata_triflex" "pata_via" "pata_winbond" "quota_v1" "quota_v2" "sata_inic162x" "sata_nv" "sata_promise" "sata_qstor" "sata_sil" "sata_sil24" "sata_sis" "sata_svw" "sata_sx4" "sata_uli" "sata_via" "sata_vsc" "sbp2" "sd_mod" "sdhci_acpi" "sdhci_pci" "serio" "sha256" "sr_mod" "surface_aggregator" "surface_aggregator_registry" "surface_hid" "surface_hid_core" "uas" "uhci_hcd" "usbhid" "usb_storage" "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "virtio_balloon" "virtio_console" "vmxnet3" "vsock" "vmw_balloon" "vmw_vmci" "vmwgfx" "vmw_vsock_vmci_transport" "xhci_pci" ];
boot.initrd.compressor="gzip";
boot.initrd.extraUtilsCommands = ''
  copy_bin_and_libs "\${pkgs.bash}/bin/bash"
  copy_bin_and_libs "\${pkgs.util-linux}/bin/blkid"
  copy_bin_and_libs "\${pkgs.cryptsetup}/bin/cryptsetup"
  copy_bin_and_libs "\${pkgs.coreutils}/bin/cut"
  copy_bin_and_libs "\${pkgs.e2fsprogs}/bin/e2fsck"
  copy_bin_and_libs "\${pkgs.findutils}/bin/find"
  copy_bin_and_libs "\${pkgs.gnugrep}/bin/grep"
  copy_bin_and_libs "\${pkgs.util-linux}/bin/losetup"
  copy_bin_and_libs "\${pkgs.util-linux}/bin/lsblk"
  copy_bin_and_libs "\${pkgs.ntfs3g}/bin/ntfs-3g"
  copy_bin_and_libs "\${pkgs.ntfs3g}/bin/ntfsfix"
  copy_bin_and_libs "\${pkgs.procps}/bin/ps"
  copy_bin_and_libs "\${pkgs.kbd}/bin/setfont"
  copy_bin_and_libs "\${pkgs.util-linux}/bin/setsid"
'';
boot.initrd.preLVMCommands = ''
INITNIXOS
add_linuxloops_recovery
add_linuxloops_main
echo -e "'';\n}\nNIXOSLINUXLOOPS\n" >> "${bootstrapdir}"/tmp/linuxloops/install_initramfs
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_initramfs
}

generate_iso_init()
{
add_linuxloops_pre
add_linuxloops_recovery
add_linuxloops_udev_start
add_linuxloops_main
add_linuxloops_udev_end
add_linuxloops_post
}

generate_install_initramfs()
{
if [ "${initramfs_type}" == "initcpio" ] || [ "${initramfs_type}" == "initramfstools" ] || [ "${initramfs_type}" == "dracut" ] || [ "${initramfs_type}" == "nixos_config" ] || [ "${initramfs_type}" == "iso_init" ]; then
	generate_"${initramfs_type}"
fi
}

generate_install_swap()
{
cat >"${bootstrapdir}"/tmp/linuxloops/install_swap <<CREATESWAP
#!/bin/bash
set -e
echo "Please wait while the swap file is being generated..."
mkdir -p /mnt/var/swap
truncate -s 0 /mnt/var/swap/swapfile
if [ "${root_fstype}" == "btrfs" ]; then chattr +C /mnt/var/swap/swapfile; fi
fallocate -l "${swap_size}"G /mnt/var/swap/swapfile
chmod 0600 /mnt/var/swap/swapfile
mkswap /mnt/var/swap/swapfile
CREATESWAP
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_swap
}

generate_install_bootloader()
{
if [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ] || [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/install_bootloader <<INSTALLEFI
#!/bin/bash
set -e
if [ "${install_type}" == "image" ]; then cmdline="\\\\\\\${linuxloops_args}"; fi
if [ "${initramfs_type}" == "initcpio" ]; then
	if [ "${root_encryption}" == "Yes" ]; then if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} "; fi; cmdline="\${cmdline}cryptdevice=UUID=\$(blkid -s UUID -o value "${root_partition}"):luks-\$(blkid -s UUID -o value "${root_partition}") rd.luks.uuid=\$(blkid -s UUID -o value "${root_partition}")"; fi
elif [ "${initramfs_type}" == "initramfstools" ]; then
	if [ "${root_encryption}" == "Yes" ]; then if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} "; fi; cmdline="\${cmdline}cryptopts=target=luks-\$(blkid -s UUID -o value "${root_partition}"),source=/dev/disk/by-uuid/\$(blkid -s UUID -o value "${root_partition}"),luks"; fi
elif [ "${initramfs_type}" == "dracut" ] || [ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "Fedora-Atomic" ]; then
	if [ "${root_encryption}" == "Yes" ]; then if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} "; fi; cmdline="\${cmdline}rd.luks.uuid=\$(blkid -s UUID -o value "${root_partition}")"; fi
fi
if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
	if [ "${root_fstype}" == "btrfs" ]; then
		if [ "${distribution}" != "Pop" ] && [ "${distribution}" != "Zorin" ]; then
			if [ "${root_encryption}" == "Yes" ]; then
				if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} resume=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) resume_offset=\$(btrfs inspect-internal map-swapfile -r /var/swap/swapfile)"; else cmdline="resume=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) resume_offset=\$(btrfs inspect-internal map-swapfile -r /var/swap/swapfile)"; fi
			else
				if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} resume=UUID=\$(blkid -s UUID -o value ${root_partition}) resume_offset=\$(btrfs inspect-internal map-swapfile -r /var/swap/swapfile)"; else cmdline="resume=UUID=\$(blkid -s UUID -o value ${root_partition}) resume_offset=\$(btrfs inspect-internal map-swapfile -r /var/swap/swapfile)"; fi
			fi
		fi
	else
		if [ "${root_encryption}" == "Yes" ]; then
			if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} resume=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) resume_offset=\$(filefrag -v /var/swap/swapfile | head -4 | tail -1 | tr -s ' ' | cut -d' ' -f5 | cut -d'.' -f1)"; else cmdline="resume=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) resume_offset=\$(filefrag -v /var/swap/swapfile | head -4 | tail -1 | tr -s ' ' | cut -d' ' -f5 | cut -d'.' -f1)"; fi
		else
			if [ ! -z "\${cmdline}" ]; then cmdline="\${cmdline} resume=UUID=\$(blkid -s UUID -o value ${root_partition}) resume_offset=\$(filefrag -v /var/swap/swapfile | head -4 | tail -1 | tr -s ' ' | cut -d' ' -f5 | cut -d'.' -f1)"; else cmdline="resume=UUID=\$(blkid -s UUID -o value ${root_partition}) resume_offset=\$(filefrag -v /var/swap/swapfile | head -4 | tail -1 | tr -s ' ' | cut -d' ' -f5 | cut -d'.' -f1)"; fi
		fi
	fi
fi
if [ ! "${distribution}" == "Artix" ] && [ ! "${distribution}" == "Devuan" ] && [ ! "${distribution}" == "Gentoo" ] && [ ! "${distribution}" == "Void" ]; then
	if [ ! -z "${kernel_parameters}" ]; then
		cmdline_extra="systemd.log_target=null quiet splash loglevel=3 ${kernel_parameters}"
	else
		cmdline_extra="systemd.log_target=null quiet splash loglevel=3"
	fi
else
	if [ ! -z "${kernel_parameters}" ]; then
		cmdline_extra="quiet splash loglevel=3 ${kernel_parameters}"
	else
		cmdline_extra="quiet splash loglevel=3"
	fi
fi
cat >/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
#!/bin/bash
set -e
cat >/etc/default/grub <<'GRUBDEFAULTS'
GRUB_DISTRIBUTOR="\$(if [ "${distribution}" == "MX" ]; then echo "MX"; elif [ "${distribution}" == "Parrot" ]; then echo "Parrot OS"; elif [ "${distribution}" == "SteamOS" ]; then echo "SteamOS"; elif [ "${distribution}" == "Proxmox" ]; then echo "Proxmox Virtual Environment"; elif [ -f /etc/system-release ]; then echo "\\\$(sed 's, release .*$,,g' /etc/system-release)"; elif [ ! -z "\$(command -v lsb_release)" ]; then echo "\\\$(lsb_release -is 2> /dev/null || echo "${distribution}")"; else echo "${distribution}"; fi)"
GRUB_CMDLINE_LINUX_DEFAULT="\${cmdline} \${cmdline_extra}"
GRUB_CMDLINE_LINUX_RECOVERY="\${cmdline} init=/bin/bash"
GRUB_CMDLINE_XEN=""
GRUB_CMDLINE_XEN_DEFAULT="${xen_cmdline_extra}"
GRUB_TIMEOUT_STYLE=$(if [ ! -z "${grub_hide}" ] && [ "${grub_hide}" == "Yes" ]; then echo "\"hidden\""; else echo "\"menu\""; fi)
GRUB_TIMEOUT=$(if [ ! -z "${grub_hide}" ] && [ "${grub_hide}" == "Yes" ]; then echo "2"; else echo "5"; fi)
GRUB_DISABLE_OS_PROBER=true
GRUB_ENABLE_BLSCFG=false
GRUBDEFAULTS
if [ "${install_type}" == "image" ] && [ ! -z "${grub_disable_recordfail}" ] && [ "${grub_disable_recordfail}" == "Yes" ]; then
	echo -e '#!/bin/sh\nif [ -f /etc/grub.d/00_header ]; then sed -i "s@{recordfail}@{norecordfail}@g" /etc/grub.d/00_header; fi' > /etc/grub.d/00_disable_recordfail
	chmod 0755 /etc/grub.d/00_disable_recordfail
fi
if [ "${live}" == "Yes" ]; then echo -e "GRUB_DISABLE_SUBMENU=true\nGRUB_DISABLE_RECOVERY=true" >> /etc/default/grub; fi
if [ -d "/etc/default/grub.d" ]; then for cfgfile in /etc/default/grub.d/*.cfg; do echo '' > \\\${cfgfile}; done; fi
for i in \\\$(find /etc/grub.d | grep debian_theme); do chmod 0644 \\\$i; done
for i in \\\$(find /etc/grub.d | grep fallback_counting); do chmod 0644 \\\$i; done
for i in \\\$(find /etc/grub.d | grep menu_auto_hide); do chmod 0644 \\\$i; done
for i in \\\$(find /etc/grub.d | grep menu_show_once); do chmod 0644 \\\$i; done
for i in \\\$(find /etc/grub.d | grep reset_boot_success); do chmod 0644 \\\$i; done
REINSTALLBOOTLOADER
if [ "${install_type}" == "image" ]; then
	cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
for i in \\\$(find /etc/grub.d | grep uefi-firmware); do chmod 0644 \\\$i; done
REINSTALLBOOTLOADER
fi
cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
rm -rf /boot/efi/EFI
REINSTALLBOOTLOADER
if [ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "Fedora-Atomic" ]; then
	if [ "${root_encryption}" == "Yes" ]; then
		if [ "${root_fstype}" == "btrfs" ]; then
			cmdline_root="root=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) rw rootflags=subvol=@"
		else
			cmdline_root="root=UUID=\$(blkid -s UUID -o value /dev/mapper/luks-\$(blkid -s UUID -o value ${root_partition})) rw"
		fi
	else
		if [ "${root_fstype}" == "btrfs" ]; then
			cmdline_root="root=UUID=\$(blkid -s UUID -o value ${root_partition}) rw rootflags=subvol=@"
		else
			cmdline_root="root=UUID=\$(blkid -s UUID -o value ${root_partition}) rw"
		fi
	fi
	for i in \$(echo \${cmdline_root} \${cmdline} \${cmdline_extra} | sed -e 's@ @\n@g'); do kargs="\${kargs} --append-if-missing=\${i}"; done
	cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
rpm-ostree kargs \${kargs}
echo -e 'add_drivers+=" 8250_dw aes amdgpu atkbd btrfs cbc dm-crypt exfat ext4 fuse i8042 i915 intel_lpss intel_lpss_pci loop nouveau nvme quota_v1 quota_v2 serio sha256 surface_aggregator surface_aggregator_registry surface_hid surface_hid_core usbhid xhci_pci "' > /etc/dracut.conf.d/99-linuxloops.conf
echo -e 'install_items+=" /etc/vconsole.conf /usr/bin/bash /usr/sbin/blkid /usr/sbin/cryptsetup /usr/bin/cut /usr/sbin/e2fsck /usr/bin/find /usr/bin/grep /usr/sbin/losetup /usr/bin/lsblk /usr/bin/ntfs-3g /usr/bin/ntfsfix /usr/bin/ps /usr/bin/setfont /usr/bin/setsid /usr/lib/systemd/systemd-sysroot-fstab-check "' >> /etc/dracut.conf.d/99-linuxloops.conf
echo 'hostonly=\"no\"' >> /etc/dracut.conf.d/99-linuxloops.conf
rpm-ostree initramfs --enable
curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/ostreedev/ostree/raw/refs/heads/main/src/boot/grub2/grub2-15_ostree -o /etc/grub.d/15_ostree
if [ "${install_type}" == "image" ]; then
	sed "s#ostree admin instutil grub2-generate#ostree admin instutil grub2-generate | sed 's|linux16 |linux |g' | sed 's|initrd16 |initrd $(if [ "${root_fstype}" == "btrfs" ]; then echo /@boot; fi)/linuxloops/linuxloops.img |g'$(if [ "${root_fstype}" == "btrfs" ]; then echo " | sed 's| /ostree| /@boot/ostree|g'"; fi)#g" /etc/grub.d/15_ostree > /etc/grub.d/15_ostree_linuxloops
else
	sed "s#ostree admin instutil grub2-generate#ostree admin instutil grub2-generate | sed 's|linux16 |linux |g' | sed 's|initrd16 |initrd |g'$(if [ "${root_fstype}" == "btrfs" ]; then echo " | sed 's| /ostree| /@boot/ostree|g'"; fi)#g" /etc/grub.d/15_ostree > /etc/grub.d/15_ostree_linuxloops
fi
chmod 0644 /etc/grub.d/15_ostree
chmod 0755 /etc/grub.d/15_ostree_linuxloops
mkdir /boot/grub2
ln -s ../loader/grub.cfg /boot/grub2/grub.cfg
bootupctl backend install /
cat >/boot/efi/EFI/fedora/grub.cfg <<'EFI_GRUB_CFG'
search --no-floppy --root-dev-only --fs-uuid --set=dev \$(blkid -s UUID -o value ${boot_partition})
set prefix=(\\\$dev)$(if [ "${root_fstype}" == "btrfs" ]; then echo /@boot; fi)/grub2
export \\\$prefix
configfile \\\$prefix/grub.cfg
EFI_GRUB_CFG
REINSTALLBOOTLOADER
	chmod 0755 /boot/linuxloops/reinstall-bootloader
	/boot/linuxloops/reinstall-bootloader
	exit 0
elif [ -d /boot/grub2 ]; then
	cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
grub2-mkconfig -o /boot/grub2/grub.cfg
REINSTALLBOOTLOADER
	if [ "${distribution}" == "OpenSUSE" ]; then
		cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
shim-install --no-nvram
shim-install --removable --no-nvram
REINSTALLBOOTLOADER
	elif [ "${distribution}" == "Qubes" ]; then
cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
dnf --setopt=reposdir=/etc/yum.repos.d/ reinstall -y shim-* grub2-efi-* grub2-common
mkdir -p /boot/efi/EFI/BOOT
cp -r /boot/efi/EFI/qubes/* /boot/efi/EFI/BOOT/
mv /boot/efi/EFI/BOOT/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
REINSTALLBOOTLOADER
	else
		cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
dnf reinstall -y shim-* grub2-efi-* grub2-common
cp /boot/efi/EFI/"${bootloader_id}"/grubx64.efi /boot/efi/EFI/BOOT/grubx64.efi
cp /boot/efi/EFI/"${bootloader_id}"/grub.cfg /boot/efi/EFI/BOOT/grub.cfg
REINSTALLBOOTLOADER
	fi
	cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
find /boot/efi -name "*.rpmsave" -type f -delete
REINSTALLBOOTLOADER
	if [ "${distribution}" == "AlmaLinux" ] || [ "${distribution}" == "OpenSUSE" ] || [ "${distribution}" == "RockyLinux" ]; then
		chmod 0755 /boot/linuxloops/reinstall-bootloader
		/boot/linuxloops/reinstall-bootloader
		if [ -z "\$(find /boot/efi/EFI/BOOT/BOOTX64.EFI 2> /dev/null)" ]; then echo "Warning: The bootloader is not installed in the removable path."; fi
		if [ -z "\$(find /boot/efi/EFI/"${bootloader_id}"/"${bootloader_name}" 2> /dev/null)" ]; then echo "The bootloader is not correctly installed"; exit 1; fi
		exit 0
	fi
else
	if [ ! -z \$(command -v debconf-set-selections) ]; then
		cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
echo "grub-efi-amd64 grub2/update_nvram boolean false" | debconf-set-selections
echo "grub-efi-amd64 grub-efi/install_devices multiselect /dev/disk/by-uuid/\$(blkid -s UUID -o value "${efi_partition}")" | debconf-set-selections
REINSTALLBOOTLOADER
		if [ "${distribution}" != "Proxmox" ]; then
		cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
dpkg-divert --divert /usr/sbin/grub-install.real --rename /usr/sbin/grub-install
REINSTALLBOOTLOADER
		fi
		cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
cat >/usr/sbin/grub-install <<'GRUBINSTALL'
#!/bin/sh
grub-install.real "\\\$@" --bootloader-id="${bootloader_id}"
# Do not use removable as Ubuntu will install the live iso version in that case which has a specific GRUB configuration path
grub-install.real "\\\$@" --bootloader-id="BOOT"
rm -f /boot/efi/EFI/BOOT/BOOTX64.EFI
if [ -f /boot/efi/EFI/BOOT/shimx64.efi ]; then mv /boot/efi/EFI/BOOT/shimx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI; else mv /boot/efi/EFI/BOOT/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI; fi
find /boot/efi -type f -iname fbx64.efi -exec rm {} \;
find /boot/efi -type f -iname bootx64.csv -exec rm {} \;
GRUBINSTALL
chmod 0755 /usr/sbin/grub-install
grub-install --target=x86_64-efi --efi-directory=/boot/efi
REINSTALLBOOTLOADER
	elif [ "${distribution}" == "Arch" ] || [ "${distribution}" == "Artix" ] || [ "${distribution}" == "BlendOS" ] || [ "${distribution}" == "CachyOS" ] || [ "${distribution}" == "KDE" ] || [ "${distribution}" == "Manjaro" ] || [ "${distribution}" == "SteamOS" ]; then
		cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
pacman -Syu --noconfirm --needed git fakeroot
git clone https://aur.archlinux.org/shim-signed.git /tmp/shim-signed
chown -R 'nobody':'nobody' /tmp/shim-signed
sudo -u nobody bin/bash -c "cd /tmp/shim-signed && makepkg -s"
pacman -U --noconfirm /tmp/shim-signed/*.pkg.tar.*
mkdir -p /etc/pacman.d/hooks
cat >/etc/pacman.d/hooks/99-secureboot-grub.hook <<PACMANHOOK
[Trigger]
Operation = Install
Operation = Upgrade
Type = File
Target = usr/lib/grub/*

[Action]
Description = Installing GRUB with grub-install
Depends = grub
When = PostTransaction
Exec = /bin/sh -c secureboot-install
PACMANHOOK
cat >/usr/sbin/secureboot-install <<'SECUREBOOTINSTALL'
#!/bin/bash
set -e
grub-install --target=x86_64-efi --efi-directory=/boot/efi --no-nvram --sbat=/usr/share/grub/sbat.csv --modules="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs zfs zfscrypt zfsinfo" --bootloader-id="${bootloader_id}"
mkdir -p /boot/efi/EFI/BOOT
cp /boot/efi/EFI/"${bootloader_id}"/grubx64.efi /boot/efi/EFI/BOOT/grubx64.efi
cp /usr/share/shim-signed/shimx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
cp /usr/share/shim-signed/shimx64.efi /boot/efi/EFI/"${bootloader_id}"/shimx64.efi
cp /usr/share/shim-signed/mmx64.efi /boot/efi/EFI/BOOT/mmx64.efi
cp /usr/share/shim-signed/mmx64.efi /boot/efi/EFI/"${bootloader_id}"/mmx64.efi
if [ ! -z "\\\$(command -v sbverify)" ] && [ ! -z "\\\$(command -v sbattach)" ] && [ ! -z "\\\$(command -v sbsign)" ] && [ -f /etc/secureboot_key/MOK.key ] && [ -f /etc/secureboot_key/MOK.crt ]; then
	for grubefi in \\\$(find /boot/efi/EFI/BOOT/grub.efi 2> /dev/null) \\\$(find /boot/efi/EFI/"${bootloader_id}"/grub.efi 2> /dev/null) \\\$(find /boot/efi/EFI/BOOT/grubx64.efi 2> /dev/null) \\\$(find /boot/efi/EFI/"${bootloader_id}"/grubx64.efi 2> /dev/null); do
		for sig in \\\$(sbverify --list \\\$grubefi | grep '^signature' | sed 's@signature @@g' | sort -r); do sbattach --signum \\\$sig --remove \\\$grubefi; done
		sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output \\\$grubefi \\\$grubefi
	done
fi
SECUREBOOTINSTALL
chmod 0755 /usr/sbin/secureboot-install
secureboot-install
REINSTALLBOOTLOADER
	elif [ "${distribution}" == "Gentoo" ]; then
		cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
mkdir /tmp/grub
cat >/tmp/grub/sbat.csv <<'GRUBSBAT'
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
grub,3,Free Software Foundation,grub,2:\\\$(grub-install -V | cut -d' ' -f3),https//www.gnu.org/software/grub/
grub.$(echo ${distribution} | tr [:upper:] [:lower:]),1,${distribution} Linux,grub,2:\\\$(grub-install -V | cut -d' ' -f3),https//www.gnu.org/software/grub/
GRUBSBAT
grub-install --target=x86_64-efi --efi-directory=/boot/efi --no-nvram --sbat=/tmp/grub/sbat.csv --modules="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs zfs zfscrypt zfsinfo"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --no-nvram --removable --sbat=/tmp/grub/sbat.csv --modules="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs zfs zfscrypt zfsinfo"
if [ -f /usr/share/shim/BOOTX64.EFI ]; then
	mv /boot/efi/EFI/BOOT/BOOTX64.EFI /boot/efi/EFI/BOOT/grubx64.efi
	cp /usr/share/shim/BOOTX64.EFI /boot/efi/EFI/BOOT/BOOTX64.EFI
	cp /usr/share/shim/BOOTX64.EFI /boot/efi/EFI/"${bootloader_id}"/shimx64.efi
	cp /usr/share/shim/mmx64.efi /boot/efi/EFI/BOOT/mmx64.efi
	cp /usr/share/shim/mmx64.efi /boot/efi/EFI/"${bootloader_id}"/mmx64.efi
fi
REINSTALLBOOTLOADER
	else
cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
grub-install --target=x86_64-efi --efi-directory=/boot/efi --no-nvram --modules="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs zfs zfscrypt zfsinfo"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --no-nvram --removable --modules="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs zfs zfscrypt zfsinfo"
REINSTALLBOOTLOADER
	fi
cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
mkdir -p /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
REINSTALLBOOTLOADER
fi
cat >>/boot/linuxloops/reinstall-bootloader <<REINSTALLBOOTLOADER
if [ ! -z "\\\$(command -v sbverify)" ] && [ ! -z "\\\$(command -v sbattach)" ] && [ ! -z "\\\$(command -v sbsign)" ] && [ -f /etc/secureboot_key/MOK.key ] && [ -f /etc/secureboot_key/MOK.crt ]; then
	for grubefi in \\\$(find /boot/efi/EFI/BOOT/grub.efi 2> /dev/null) \\\$(find /boot/efi/EFI/"${bootloader_id}"/grub.efi 2> /dev/null) \\\$(find /boot/efi/EFI/BOOT/grubx64.efi 2> /dev/null) \\\$(find /boot/efi/EFI/"${bootloader_id}"/grubx64.efi 2> /dev/null); do
			for sig in \\\$(sbverify --list "\\\$grubefi" | grep '^signature' | sed 's@signature @@g' | sort -r); do sbattach --signum "\\\$sig" --remove "\\\$grubefi"; done
			sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output "\\\$grubefi" "\\\$grubefi"
	done
fi
REINSTALLBOOTLOADER
chmod 0755 /boot/linuxloops/reinstall-bootloader
/boot/linuxloops/reinstall-bootloader
# Due to a bug with certain shim binaries, use the Ubuntu shim for initial key registration.
if [ "${distribution}" == "Debian" ] || [ "${distribution}" == "Devuan" ] || [ "${distribution}" == "Gentoo" ] || [ "${distribution}" == "LMDE" ] || [ "${distribution}" == "MX" ] || [ "${distribution}" == "PikaOS" ] || [ "${distribution}" == "Proxmox" ]; then
	mkdir /tmp/ubuntu_shim
	curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f http://archive.ubuntu.com/ubuntu/pool/main/s/shim-signed/shim-signed_1.59+15.8-0ubuntu2_amd64.deb -o /tmp/ubuntu_shim/shim.deb
	(cd /tmp/ubuntu_shim && ar p shim.deb data.tar.xz | tar -xJ)
	cp /tmp/ubuntu_shim/usr/lib/shim/shimx64.efi.signed.latest /boot/efi/EFI/BOOT/BOOTX64.EFI
	cp /tmp/ubuntu_shim/usr/lib/shim/shimx64.efi.signed.latest /boot/efi/EFI/"${bootloader_id}"/shimx64.efi
	cp /tmp/ubuntu_shim/usr/lib/shim/mmx64.efi /boot/efi/EFI/BOOT/mmx64.efi
	cp /tmp/ubuntu_shim/usr/lib/shim/mmx64.efi /boot/efi/EFI/"${bootloader_id}"/mmx64.efi
fi
if [ -z "\$(find /boot/efi/EFI/BOOT/BOOTX64.EFI 2> /dev/null)" ]; then echo "Warning: The bootloader is not installed in the removable path."; fi
if [ -z "\$(find /boot/efi/EFI/"${bootloader_id}"/"${bootloader_name}" 2> /dev/null)" ]; then echo "The bootloader is not correctly installed"; exit 1; fi
INSTALLEFI
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_bootloader
}

generate_install_live()
{
if [ ! "${live}" == "Yes" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/install_live <<INSTALLLIVE
#!/bin/bash
set -e
echo "live ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
cat >/etc/polkit-1/rules.d/49-nopasswd_live.rules <<'POLKIT'
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("live")) {
        return polkit.Result.YES ;
    }
}) ;
POLKIT
cat >/usr/bin/linuxloops <<'LIVELAUNCHER'
#!/bin/bash
set -e
sudo curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/sebanc/linuxloops/raw/refs/heads/main/linuxloops -o /usr/bin/linuxloops.real || zenity --height=480 --width=640 --title="LinuxLoops installer" --error --text="Please make sure you have internet connectivity before running this program.\n" 2>/dev/null
sudo chmod 0755 /usr/bin/linuxloops.real
bash /usr/bin/linuxloops.real "\${@}"
LIVELAUNCHER
chmod 0755 /usr/bin/linuxloops
mkdir -p /usr/share/glib-2.0/schemas
cat >/usr/share/glib-2.0/schemas/zz_noscreenlock.gschema.override <<'DCONF'
[org.cinnamon.desktop.screensaver]
lock-delay=0
lock-enabled=false
DCONF
if [ ! -z "\$(command -v glib-compile-schemas)" ]; then glib-compile-schemas /usr/share/glib-2.0/schemas/; fi
mkdir -p /etc/repart.d
echo -e '[Partition]\nType=linux-generic' > /etc/repart.d/50-root.conf
cat >/etc/systemd/system/live-configuration.service <<'LIVE_CONFIGURATION_SERVICE'
[Unit]
Description=Apply linuxloops live configuration
DefaultDependencies=no
After=systemd-remount-fs.service
Before=systemd-modules-load.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c "/usr/bin/live-configuration"

[Install]
WantedBy=local-fs-pre.target
LIVE_CONFIGURATION_SERVICE
systemctl enable live-configuration.service
mkdir -p /boot/linuxloops
cat >/usr/bin/live-configuration <<'LIVE_CONFIGURATION_SCRIPT'
#!/bin/bash
variant=""
if grep -qi 'variant_wifi' /proc/cmdline; then variant="wifi"; fi
if grep -qi 'variant_nvidia' /proc/cmdline; then variant="nvidia"; fi

for i in \$(ls /etc/modprobe.d/{broadcom,nvidia}*.conf) \$(ls /etc/modules-load.d/{broadcom,nvidia}*.conf); do
	conf=\${i%.*}
	rm -f \${conf}.disabled
	mv \${conf}.conf \${conf}.disabled
done

if [ "\${variant}" == "wifi" ]; then
	for i in \$(ls /etc/modprobe.d/broadcom*.disabled) \$(ls /etc/modules-load.d/broadcom*.disabled); do
		conf=\${i%.*}
		mv \${conf}.disabled \${conf}.conf
	done
	echo -e "blacklist nvidia" > /etc/modprobe.d/live-configuration.conf
elif [ "\${variant}" == "nvidia" ]; then
	for i in \$(ls /etc/modprobe.d/nvidia*.disabled) \$(ls /etc/modules-load.d/nvidia*.disabled); do
		conf=\${i%.*}
		mv \${conf}.disabled \${conf}.conf
	done
	echo -e "blacklist wl" > /etc/modprobe.d/live-configuration.conf
else
	echo -e "blacklist nvidia\nblacklist wl" > /etc/modprobe.d/live-configuration.conf
fi
LIVE_CONFIGURATION_SCRIPT
chmod 0755 /usr/bin/live-configuration
sed 's@"\\\${OS}"@"\${OS} (with additional wifi drivers)"@g' /etc/grub.d/10_linux > /etc/grub.d/10_linux_wifi
sed -i 's@\\\${GRUB_CMDLINE_LINUX}@\${GRUB_CMDLINE_LINUX} variant_wifi@g' /etc/grub.d/10_linux_wifi
chmod 0755 /etc/grub.d/10_linux_wifi
sed 's@"\\\${OS}"@"\${OS} (with nvidia proprietary gpu drivers)"@g' /etc/grub.d/10_linux > /etc/grub.d/10_linux_nvidia
sed -i 's@\\\${GRUB_CMDLINE_LINUX}@\${GRUB_CMDLINE_LINUX} module_blacklist=nouveau nvidia-drm.modeset=1 ibt=off variant_nvidia@g' /etc/grub.d/10_linux_nvidia
chmod 0755 /etc/grub.d/10_linux_nvidia
mkdir -p /etc/systemd/system-shutdown
cat >/etc/systemd/system-shutdown/nvidia.shutdown <<'NVIDIA_SHUTDOWNFIX'
#!/bin/sh
for MODULE in nvidia_drm nvidia_modeset nvidia_uvm nvidia; do
	if lsmod | grep "\$MODULE" &> /dev/null; then rmmod \$MODULE; fi
done
NVIDIA_SHUTDOWNFIX
chmod 0755 /etc/systemd/system-shutdown/nvidia.shutdown
rm -rf /lib/firmware/bnx2x /lib/firmware/dpaa2 /lib/firmware/liquidio /lib/firmware/mellanox /lib/firmware/mrvl/prestera /lib/firmware/netronome /lib/firmware/qcom /lib/firmware/qed /lib/firmware/ti-connectivity
if [ "${distribution}" == "Linuxmint" ]; then
	rm -r /usr/share/icons/Bibata-Original*
	rm -r /usr/share/icons/Mint-X*
	DEBIAN_FRONTEND=noninteractive apt install --purge -y \$(apt search nvidia | grep nvidia-driver | grep -v '\-bin' | grep -v '\-open' | grep -v '\-server' | tail -1 | grep -o -P '(nvidia-driver-).*' | cut -d' ' -f1 | cut -d '/' -f1) broadcom-sta-dkms firmware-b43-installer curl python3-venv python3-gi gir1.2-gtk-3.0 gir1.2-webkit2-4.1 xz-utils evince file-roller firefox gedit gparted language-selector-gnome qemu-guest-agent spice-vdagent
else
	DEBIAN_FRONTEND=noninteractive apt install --purge -y nvidia-driver nvidia-vulkan-icd broadcom-sta-dkms firmware-b43-installer curl python3-venv python3-gi gir1.2-gtk-3.0 gir1.2-webkit2-4.1 xz-utils evince file-roller firefox-esr gedit gparted qemu-guest-agent spice-vdagent
fi
apt clean
sudo -u '${useraccount_name}' bash << 'INSTALLERICONS'
mkdir -p \$HOME/Desktop
cat >\$HOME/Desktop/linuxloops.desktop <<'LIVEDESKTOPICON'
[Desktop Entry]
Name=Linuxloops installer
Exec=linuxloops
Icon=system-software-install
Terminal=true
Type=Application
StartupNotify=false
LIVEDESKTOPICON
chmod 0755 \$HOME/Desktop/linuxloops.desktop
mkdir -p \$HOME/.local/share/applications
cat >\$HOME/.local/share/applications/linuxloops.desktop <<'LIVEMENUICON'
[Desktop Entry]
Name=Linuxloops installer
Exec=linuxloops
Icon=system-software-install
Terminal=true
Type=Application
Categories=System;Filesystem;
LIVEMENUICON
INSTALLERICONS
INSTALLLIVE
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_live
}

generate_cleanup()
{
cat >"${bootstrapdir}"/tmp/linuxloops/cleanup <<CLEANUP
#!/bin/bash
set -e
if [ ! -z "\$(command -v apt)" ]; then
	if [ "${distribution}" == "Elementary" ] || [ "${distribution}" == "Linuxmint" ] || [ "${distribution}" == "Neon" ] || [ "${distribution}" == "Pop" ] || [ "${distribution}" == "Ubuntu" ] || [ "${distribution}" == "Zorin" ]; then DEBIAN_FRONTEND=noninteractive apt install --purge -y \$(check-language-support -l ${packages_locale}); fi
	rm -f /etc/apt/apt.conf.d/99linuxloops
	DEBIAN_FRONTEND=noninteractive apt autoremove -y
elif [ ! -z "\$(command -v dnf)" ]; then
	if [ "${distribution}" == "Qubes" ]; then
		dnf --setopt=reposdir=/etc/yum.repos.d/ autoremove -y
	else
		dnf autoremove -y
	fi
elif [ ! -z "\$(command -v emerge)" ]; then
	emerge --depclean
	eselect news read new
elif [ ! -z "\$(command -v rpm-ostree)" ]; then
	echo "Cleaning up"
	rpm-ostree cleanup --base
elif [ ! -z "\$(command -v zypper)" ]; then
	sed -i 's@solver.onlyRequires = true@# solver.onlyRequires = false@g' /etc/zypp/zypp.conf
fi
rm -rf /usr/share/xsessions/lightdm-xsession.desktop /usr/share/xsessions/Xsession.desktop
CLEANUP
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/cleanup
}

generate_efi_entry()
{
cat >"${bootstrapdir}"/tmp/linuxloops/efi_entry <<EFIENTRY
#!/bin/bash
set -e
if ! mountpoint -q /sys/firmware/efi/efivars; then exit 0; fi
if [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Tails" ]; then
	if [ "${install_type}" == "disk" ] && [ -f /sys/block/\$(echo "${destination}" | sed 's@/dev/@@g')/removable ] && [ "\$(cat /sys/block/\$(echo "${destination}" | sed 's@/dev/@@g')/removable)" -eq 0 ] && [ ! -z \$(command -v efibootmgr) ]; then
		echo "Creating EFI boot manager entry..."
		if [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ]; then
			efibootmgr -c -d "${destination}" -p 12 -L "${distribution}" -l "\efi\\${bootloader_id}\\${bootloader_name}"
		else
			efibootmgr -c -d "${destination}" -p 1 -L "${distribution}" -l "\efi\\${bootloader_id}\\${bootloader_name}"
		fi
	fi
else
	if [ "${install_type}" == "disk" ] && [ -f /sys/block/\$(echo "${destination}" | sed 's@/dev/@@g')/removable ] && [ "\$(cat /sys/block/\$(echo "${destination}" | sed 's@/dev/@@g')/removable)" -eq 0 ] && [ ! -z \$(command -v efibootmgr) ]; then
		echo "Creating EFI boot manager entry..."
		efibootmgr -c -d "${destination}" -p 1 -L "${distribution}" -l "\efi\\${bootloader_id}\\${bootloader_name}"
	fi
fi
EFIENTRY
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/efi_entry
}

generare_install_userpw()
{
if [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/install_userpw <<INSTALLUSERPW
#!/bin/bash
set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib/x86_64-linux-gnu:/usr/local/lib:/usr/lib64:/usr/lib/x86_64-linux-gnu:/usr/lib:/lib64:/lib/x86_64-linux-gnu:/lib
if [ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ]; then mkdir /mnt/tmp/linuxloops; fi
cat >/mnt/tmp/linuxloops/set_userpw <<'SETUSERPW'
#!/bin/bash
set -e
echo -e '${useraccount_password}\n${useraccount_password}' | passwd '${useraccount_name}'
if [ "${distribution}" == "Proxmox" ]; then echo -e '${useraccount_password}\n${useraccount_password}' | passwd root; fi
SETUSERPW
chmod 0755 /mnt/tmp/linuxloops/set_userpw
if [ "${distribution}" == "BlendOS" ]; then
	cat >>/mnt/tmp/linuxloops/set_userpw <<BLENDOS_AKSHARA
akshara update
if [ "${environment}" != "None" ]; then if [ ! -f /.update_rootfs/usr/share/xsessions/${default_session}.desktop ] && [ ! -f /.update_rootfs/usr/share/wayland-sessions/${default_session}.desktop ]; then echo "Default session ${default_session} not found."; exit 1; fi; fi
cp /.update_rootfs/etc/mkinitcpio.conf.d/* /etc/mkinitcpio.conf.d/
cp /.update_rootfs/etc/mkinitcpio.d/* /etc/mkinitcpio.d/
rm -rf /lib/modules
cp -r /.update_rootfs/lib/modules /lib/
mkinitcpio -P
BLENDOS_AKSHARA
fi
if [ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ]; then
	sed -i '1d' /mnt/tmp/linuxloops/set_userpw
	sudo -u temp bash << 'NIXOSSETPW'
source \$HOME/.nix-profile/etc/profile.d/nix.sh
sudo \$(command -v nixos-enter) << 'NIXOSCHROOT'
set -e
/tmp/linuxloops/set_userpw
NIXOSCHROOT
NIXOSSETPW
rm -rf /mnt/tmp/*
elif [ "${systemd_init}" == "Yes" ]; then
	nsenter --pid=/tmp/pid_ns unshare --mount-proc --root=/mnt bash /tmp/linuxloops/set_userpw
	if [ -f /tmp/linuxloops/selinux_fix ]; then nsenter --pid=/tmp/pid_ns unshare --mount-proc --root=/mnt bash /tmp/linuxloops/selinux_fix; fi
else
	chroot /mnt /tmp/linuxloops/set_userpw
	if [ -f /tmp/linuxloops/selinux_fix ]; then chroot /mnt /tmp/linuxloops/selinux_fix; fi
fi
rm -f /mnt/tmp/linuxloops/set_userpw
INSTALLUSERPW
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/install_userpw
}

generate_selinux_fix()
{
if [ "${distribution}" != "AlmaLinux" ] && [ "${distribution}" != "Bazzite" ] && [ "${distribution}" != "Fedora" ] && [ "${distribution}" != "Fedora-Atomic" ] && [ "${distribution}" != "RockyLinux" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/selinux_fix <<SELINUXFIX
#!/bin/bash
set -e
mkdir -p /var/lib/bluetooth /var/lib/NetworkManager
chmod 0700 /var/lib/bluetooth /var/lib/NetworkManager
if [ "${distribution}" == "Bazzite" ] || [ "${distribution}" == "Fedora-Atomic" ]; then
	ostree admin finalize-staged
	sed -i "/(ostree:1)/,/}/d" /boot/loader/grub.cfg
	echo "Applying selinux labels..."
	echo '/var/swap(/.*)?       system_u:object_r:swapfile_t:s0' >> /etc/selinux/targeted/contexts/files/file_contexts.local
	setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts /boot
	for i in \$(ls /ostree/deploy/fedora/deploy | grep -v '\.origin'); do
		setfiles -r /ostree/deploy/fedora/deploy/\${i} -c /ostree/deploy/fedora/deploy/\${i}/etc/selinux/targeted/policy/policy.* /ostree/deploy/fedora/deploy/\${i}/etc/selinux/targeted/contexts/files/file_contexts /ostree/deploy/fedora/deploy/\${i}
	done
	setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts /etc
	setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts /var
	setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts.homedirs /var/home
	if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
		setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts.local /var/swap
	fi
	$(if [ ${#extra_partitions[@]} -ne 0 ]; then
		for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
			cat <<RELABEL_CUSTOM_MOUNT
setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts $(if [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home/*" ]] && [ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root" ] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/root/*" ]] && [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/var/*" ]]; then echo /var; fi)$(get_extra_partitions_attribute mountpoint ${i})
RELABEL_CUSTOM_MOUNT
		done
	fi)
else
	echo "Applying selinux labels..."
	echo '/var/swap(/.*)?       system_u:object_r:swapfile_t:s0' >> /etc/selinux/targeted/contexts/files/file_contexts.local
	setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts /
	setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts /boot
	setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts.homedirs /home
	if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then
		setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts.local /var/swap
	fi
	$(if [ ${#extra_partitions[@]} -ne 0 ]; then
		for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
			if [[ ! "$(get_extra_partitions_attribute mountpoint ${i})" == "/home/*" ]]; then
				cat <<RELABEL_CUSTOM_MOUNT
setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts.homedirs $(get_extra_partitions_attribute mountpoint ${i})
RELABEL_CUSTOM_MOUNT
			else
				cat <<RELABEL_CUSTOM_MOUNT
setfiles -c /etc/selinux/targeted/policy/policy.* /etc/selinux/targeted/contexts/files/file_contexts $(get_extra_partitions_attribute mountpoint ${i})
RELABEL_CUSTOM_MOUNT
			fi
		done
	fi)
fi
SELINUXFIX
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/selinux_fix
}

generate_exit_chroot()
{
if [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Tails" ]; then return; fi
cat >"${bootstrapdir}"/tmp/linuxloops/exit_chroot <<EXITCHROOT
#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib/x86_64-linux-gnu:/usr/local/lib:/usr/lib64:/usr/lib/x86_64-linux-gnu:/usr/lib:/lib64:/lib/x86_64-linux-gnu:/lib
for ROOT in \$(find /proc/*/root 2>/dev/null); do
	LINK="\$(readlink -f \${ROOT})"
	if echo "\${LINK}" | grep -q /mnt; then
		PID=\$(basename \$(dirname "\${ROOT}"))
		kill -STOP \${PID} 2>/dev/null
	fi
done
sleep 2
for ROOT in \$(find /proc/*/root 2>/dev/null); do
	LINK="\$(readlink -f \${ROOT})"
	if echo "\${LINK}" | grep -q /mnt; then
		PID=\$(basename \$(dirname "\${ROOT}"))
		kill -9 \${PID} 2>/dev/null
	fi
done
sleep 5
if mountpoint -q /mnt/tmp/linuxloops; then umount /mnt/tmp/linuxloops; fi
rm -rf /mnt/tmp/linuxloops
if mountpoint -q /mnt/tmp; then umount /mnt/tmp; fi
if mountpoint -q /mnt/run/keys; then umount /mnt/run/keys; fi
if mountpoint -q /mnt/run; then umount /mnt/run; fi
if mountpoint -q /mnt/dev/shm; then umount /mnt/dev/shm; fi
if mountpoint -q /mnt/dev/pts; then umount /mnt/dev/pts; fi
if mountpoint -q /mnt/dev/console; then umount /mnt/dev/console; fi
if mountpoint -q /mnt/dev; then umount /mnt/dev; fi
if mountpoint -q /mnt/sys/module/apparmor; then umount /mnt/sys/module/apparmor; fi
if mountpoint -q /mnt/sys/firmware/efi/efivars; then umount /mnt/sys/firmware/efi/efivars; fi
if mountpoint -q /mnt/sys; then umount /mnt/sys; fi
if mountpoint -q /mnt/proc/sys; then umount /mnt/proc/sys; fi
if mountpoint -q /mnt/proc; then umount /mnt/proc; fi
if mountpoint -q /mnt/boot/efi; then umount /mnt/boot/efi; fi
if [ -f /tmp/linuxloops/efi_loop ]; then losetup -d \$(cat /tmp/linuxloops/efi_loop); fi
if mountpoint -q /mnt/boot; then umount /mnt/boot; fi
if [ -f /tmp/linuxloops/boot_loop ]; then losetup -d \$(cat /tmp/linuxloops/boot_loop); fi
$(if [ ${#extra_partitions[@]} -ne 0 ]; then
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		cat <<UMOUNTPARTITION
if mountpoint -q "/mnt$(get_extra_partitions_attribute mountpoint ${i})"; then umount "/mnt$(get_extra_partitions_attribute mountpoint ${i})"; fi
if mountpoint -q "/mnt/var$(get_extra_partitions_attribute mountpoint ${i})"; then umount "/mnt/var$(get_extra_partitions_attribute mountpoint ${i})"; fi
UMOUNTPARTITION
	done
fi)
if mountpoint -q /mnt/sysroot; then umount /mnt/sysroot; fi
if mountpoint -q /mnt/var/swap; then umount /mnt/var/swap; fi
if mountpoint -q /mnt/root; then umount /mnt/root; fi
if mountpoint -q /mnt/home; then umount /mnt/home; fi
if mountpoint -q /mnt/var; then umount /mnt/var; fi
if mountpoint -q /mnt/efi; then umount /mnt/efi; fi
if mountpoint -q /mnt; then umount /mnt; fi
if mountpoint -q /atomic/boot/efi; then umount /atomic/boot/efi; fi
if mountpoint -q /atomic/boot; then umount /atomic/boot; fi
$(if [ ${#extra_partitions[@]} -ne 0 ]; then
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		cat <<UMOUNTPARTITION
if mountpoint -q "/atomic$(get_extra_partitions_attribute mountpoint ${i})"; then umount "/atomic$(get_extra_partitions_attribute mountpoint ${i})"; fi
UMOUNTPARTITION
	done
fi)
if mountpoint -q /atomic/var/swap; then umount /atomic/var/swap; fi
if mountpoint -q /atomic/root; then umount /atomic/root; fi
if mountpoint -q /atomic/home; then umount /atomic/home; fi
if mountpoint -q /atomic; then umount /atomic; fi
EXITCHROOT
chmod 0755 "${bootstrapdir}"/tmp/linuxloops/exit_chroot
}

end_bootstrap()
{
rm -f "${bootstrapdir}"/tmp/linuxloops/setup_and_mount_rootfs "${bootstrapdir}"/tmp/linuxloops/install_userpw "${chrootdir}"/tmp/linuxloops/set_userpw
for ROOT in $(find /proc/*/root 2>/dev/null); do
	LINK="$(readlink -f ${ROOT})"
	if echo "${LINK}" | grep -q "${bootstrapdir}"; then
		PID=$(basename $(dirname "${ROOT}"))
		kill -STOP ${PID} 2>/dev/null
	fi
done
sleep 2
for ROOT in $(find /proc/*/root 2>/dev/null); do
	LINK="$(readlink -f ${ROOT})"
	if echo "${LINK}" | grep -q "${bootstrapdir}"; then
		PID=$(basename $(dirname "${ROOT}"))
		kill -9 ${PID} 2>/dev/null
	fi
done
sleep 5
if mountpoint -q "${chrootdir}"/tmp/linuxloops; then umount "${chrootdir}"/tmp/linuxloops; fi
if mountpoint -q "${chrootdir}"/tmp; then umount "${chrootdir}"/tmp; fi
if mountpoint -q "${chrootdir}"/run/keys; then umount "${chrootdir}"/run/keys; fi
if mountpoint -q "${chrootdir}"/run; then umount "${chrootdir}"/run; fi
if mountpoint -q "${chrootdir}"/dev/shm; then umount "${chrootdir}"/dev/shm; fi
if mountpoint -q "${chrootdir}"/dev/pts; then umount "${chrootdir}"/dev/pts; fi
if mountpoint -q "${chrootdir}"/dev/console; then umount "${chrootdir}"/dev/console; fi
if mountpoint -q "${chrootdir}"/dev; then umount "${chrootdir}"/dev; fi
if mountpoint -q "${chrootdir}"/sys/module/apparmor; then umount "${chrootdir}"/sys/module/apparmor; fi
if mountpoint -q "${chrootdir}"/sys/firmware/efi/efivars; then umount "${chrootdir}"/sys/firmware/efi/efivars; fi
if mountpoint -q "${chrootdir}"/sys; then umount "${chrootdir}"/sys; fi
if mountpoint -q "${chrootdir}"/proc/sys; then umount "${chrootdir}"/proc/sys; fi
if mountpoint -q "${chrootdir}"/proc; then umount "${chrootdir}"/proc; fi
if mountpoint -q "${chrootdir}"/boot/efi; then umount "${chrootdir}"/boot/efi; fi
if mountpoint -q "${chrootdir}"/boot; then umount "${chrootdir}"/boot; fi
if [ ${#extra_partitions[@]} -ne 0 ]; then
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		if mountpoint -q "${chrootdir}$(get_extra_partitions_attribute mountpoint ${i})"; then umount "${chrootdir}$(get_extra_partitions_attribute mountpoint ${i})"; fi
		if mountpoint -q "${chrootdir}/var$(get_extra_partitions_attribute mountpoint ${i})"; then umount "${chrootdir}/var$(get_extra_partitions_attribute mountpoint ${i})"; fi
	done
fi
if mountpoint -q "${chrootdir}"/sysroot; then umount "${chrootdir}"/sysroot; fi
if mountpoint -q "${chrootdir}"/var/swap; then umount "${chrootdir}"/var/swap; fi
if mountpoint -q "${chrootdir}"/root; then umount "${chrootdir}"/root; fi
if mountpoint -q "${chrootdir}"/home; then umount "${chrootdir}"/home; fi
if mountpoint -q "${chrootdir}"/var; then umount "${chrootdir}"/var; fi
if mountpoint -q "${chrootdir}"/efi; then umount "${chrootdir}"/efi; fi
if mountpoint -q "${chrootdir}"; then umount "${chrootdir}"; fi
if mountpoint -q "${bootstrapdir}"/atomic/boot/efi; then umount "${bootstrapdir}"/atomic/boot/efi; fi
if mountpoint -q "${bootstrapdir}"/atomic/boot; then umount "${bootstrapdir}"/atomic/boot; fi
if [ ${#extra_partitions[@]} -ne 0 ]; then
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		if mountpoint -q "${bootstrapdir}/atomic$(get_extra_partitions_attribute mountpoint ${i})"; then umount "${bootstrapdir}/atomic$(get_extra_partitions_attribute mountpoint ${i})"; fi
	done
fi
if mountpoint -q "${bootstrapdir}"/atomic/var/swap; then umount "${bootstrapdir}"/atomic/var/swap; fi
if mountpoint -q "${bootstrapdir}"/atomic/root; then umount "${bootstrapdir}"/atomic/root; fi
if mountpoint -q "${bootstrapdir}"/atomic/home; then umount "${bootstrapdir}"/atomic/home; fi
if mountpoint -q "${bootstrapdir}"/atomic; then umount "${bootstrapdir}"/atomic; fi
if ([ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ]) && mountpoint -q "${chrootdir}"; then umount "${chrootdir}"; fi
if mountpoint -q "${bootstrapdir}"/tmp/linuxloops; then umount "${bootstrapdir}"/tmp/linuxloops; fi
if mountpoint -q "${bootstrapdir}"/isomount/data; then umount "${bootstrapdir}"/isomount/data; fi
if mountpoint -q "${bootstrapdir}"/isomount/efi; then umount "${bootstrapdir}"/isomount/efi; fi
if mountpoint -q "${bootstrapdir}"/isomount/iso; then umount "${bootstrapdir}"/isomount/iso; fi
if mountpoint -q "${bootstrapdir}"/isomount/roota; then umount "${bootstrapdir}"/isomount/roota; fi
if mountpoint -q "${bootstrapdir}"/isomount/rootc; then umount "${bootstrapdir}"/isomount/rootc; fi
if mountpoint -q "${bootstrapdir}"/isomount/tmp; then umount "${bootstrapdir}"/isomount/tmp; fi
if mountpoint -q "${bootstrapdir}"/isomount; then umount "${bootstrapdir}"/isomount; fi
if mountpoint -q "${bootstrapdir}"/tmp/pid_ns; then umount "${bootstrapdir}"/tmp/pid_ns; fi
if mountpoint -q "${bootstrapdir}"/tmp; then umount "${bootstrapdir}"/tmp; fi
if mountpoint -q "${bootstrapdir}"/run; then umount "${bootstrapdir}"/run; fi
if mountpoint -q "${bootstrapdir}"/dev/shm; then umount "${bootstrapdir}"/dev/shm; fi
if mountpoint -q "${bootstrapdir}"/dev/pts; then umount "${bootstrapdir}"/dev/pts; fi
if mountpoint -q "${bootstrapdir}"/dev; then umount "${bootstrapdir}"/dev; fi
if mountpoint -q "${bootstrapdir}"/sys/firmware/efi/efivars; then umount "${bootstrapdir}"/sys/firmware/efi/efivars; fi
if mountpoint -q "${bootstrapdir}"/sys; then umount "${bootstrapdir}"/sys; fi
if mountpoint -q "${bootstrapdir}"/proc; then umount "${bootstrapdir}"/proc; fi
if mountpoint -q "${bootstrapdir}"; then umount "${bootstrapdir}"; fi
if mountpoint -q "${homebinddir}"; then umount "${homebinddir}"; fi
if ! mountpoint -q "${homebinddir}"; then rm -r "${homebinddir}"; fi
if [ ${#extra_partitions[@]} -ne 0 ]; then
	for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
		if [ -b /dev/mapper/luks-"$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")" ]; then cryptsetup luksClose luks-"$(blkid -s UUID -o value "${partition_path}$(( ${i} + 4 ))")"; fi
	done
fi
if [ -b /dev/mapper/luks-"$(blkid -s UUID -o value "${root_partition}")" ]; then cryptsetup luksClose luks-"$(blkid -s UUID -o value "${root_partition}")"; fi
if [ "${install_type}" == "image" ] && [ -b "${destination_device}" ]; then losetup -d "${destination_device}"; fi
for removedir in "${linuxloopsdir}"/tmp/*; do if [ -d "${removedir}" ] && ! mountpoint -q "${removedir}"; then rm -rf "${removedir}"; fi; done
if [ ! -z "${brunch}" ] || [ ! -z "${chromeos}" ]; then for removedir in /usr/local/tmp/linuxloops/*; do if [ -d "${removedir}" ] && ! mountpoint -q "${removedir}"; then rm -rf "${removedir}"; fi; done; fi
if mountpoint -q "${linuxloopsdir}"/cache/iso/rootfs; then umount "${linuxloopsdir}"/cache/iso/rootfs; fi
if mountpoint -q "${linuxloopsdir}"/cache/iso/level1; then umount "${linuxloopsdir}"/cache/iso/level1; fi
if mountpoint -q "${linuxloopsdir}"/cache/iso/level2; then umount "${linuxloopsdir}"/cache/iso/level2; fi
}

exit_with_error()
{
if [ ! -z "${gui}" ]; then
	gui_launch -m messagebox -t "Error" -q "Installation failed: ${1}" 2>/dev/null
else
	echo -e "${1}\nInstallation failed."
fi
exit 1
}

download_bootstrap()
{
local skip_gpg=0
sudo -u ${SUDO_USER} mkdir -p "${linuxloopsdir}"/cache "${linuxloopsdir}"/gnupg
sudo -u ${SUDO_USER} chmod 0700 "${linuxloopsdir}"/gnupg
if [ "${1}" == "iso" ]; then
	echo "Downloading ${distribution} iso image from ${2}"
	for i in 1 .. 3; do
		if sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f "${2}" -o "${linuxloopsdir}"/cache/"${distribution}".iso; then
			sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f ${iso_sha256sum} -o "${linuxloopsdir}"/cache/"${distribution}".iso.sha256sum
			sudo -u ${SUDO_USER} sed "s@$(basename ${2})@${linuxloopsdir}/cache/${distribution}.iso@g" "${linuxloopsdir}"/cache/"${distribution}".iso.sha256sum > "${linuxloopsdir}"/cache/"${distribution}".iso.sha256sum.mod
			if sha256sum -c "${linuxloopsdir}"/cache/"${distribution}".iso.sha256sum.mod; then
				echo "sha256sum verification succeeded"
				break
			else
				echo "sha256sum verification failed, retrying download..."
			fi
		fi
		if [ "${i}" -eq 3 ]; then if [ "${install_type}" == "image" ]; then losetup -d "${destination_device}"; fi; exit_with_error "Download of ${distribution} iso image from ${2} failed"; fi
	done
	if [ -z "$(command -v gpg)" ] || [ -z "$(command -v dirmngr)" ]; then
		echo "Warning: iso cannot be verified as gpg is not available."
		skip_gpg=1
	elif [ -z "${iso_signature}" ] || [ -z "${master_key}" ]; then
		echo "Warning: iso cannot be verified as no signature or master key provided."
		skip_gpg=1
	else
		echo "Importing master key"
		sudo -u ${SUDO_USER} gpg --homedir "${linuxloopsdir}"/gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv "${master_key}"
		echo "Downloading iso signature"
		sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f ${iso_signature} -o "${linuxloopsdir}"/cache/"${distribution}".iso.asc
		echo "Verifying iso signature"
	fi
	if [ ${skip_gpg} -eq 1 ] || sudo -u ${SUDO_USER} gpg --homedir "${linuxloopsdir}"/gnupg --verify "${linuxloopsdir}"/cache/"${distribution}".iso.asc "${linuxloopsdir}"/cache/"${distribution}".iso; then
		if [ ! -z "${4}" ]; then
			rm -rf "${linuxloopsdir}"/cache/iso
			sudo -u ${SUDO_USER} mkdir -p "${linuxloopsdir}"/cache/iso/rootfs "${linuxloopsdir}"/cache/iso/level1 "${linuxloopsdir}"/cache/iso/level2
			mount "${linuxloopsdir}"/cache/"${distribution}".iso "${linuxloopsdir}"/cache/iso/level2
			mount "${linuxloopsdir}"/cache/iso/level2"${3}" "${linuxloopsdir}"/cache/iso/level1
			mount "${linuxloopsdir}"/cache/iso/level1"${4}" "${linuxloopsdir}"/cache/iso/rootfs
			cp -aT "${linuxloopsdir}"/cache/iso/rootfs "${bootstrapdir}"
			if [ "${distribution}" == "Qubes" ]; then
				mkdir -p "${bootstrapdir}"/source
				cp -a "${linuxloopsdir}"/cache/iso/level2/Packages "${bootstrapdir}"/source/
				cp -a "${linuxloopsdir}"/cache/iso/level2/repodata "${bootstrapdir}"/source/
			fi
			umount "${linuxloopsdir}"/cache/iso/rootfs
			umount "${linuxloopsdir}"/cache/iso/level1
			umount "${linuxloopsdir}"/cache/iso/level2
		elif  [ ! -z "${3}" ]; then
			mkdir -p "${linuxloopsdir}"/cache/iso/rootfs "${linuxloopsdir}"/cache/iso/level1
			mount "${linuxloopsdir}"/cache/"${distribution}".iso "${linuxloopsdir}"/cache/iso/level1
			mount "${linuxloopsdir}"/cache/iso/level1"${3}" "${linuxloopsdir}"/cache/iso/rootfs
			cp -aT "${linuxloopsdir}"/cache/iso/rootfs "${bootstrapdir}"
			umount "${linuxloopsdir}"/cache/iso/rootfs
			umount "${linuxloopsdir}"/cache/iso/level1
		else
			mkdir -p "${linuxloopsdir}"/cache/iso/rootfs
			mount "${linuxloopsdir}"/cache/"${distribution}".iso "${linuxloopsdir}"/cache/iso/rootfs
			cp -aT "${linuxloopsdir}"/cache/iso/rootfs "${bootstrapdir}"
			umount "${linuxloopsdir}"/cache/iso/rootfs	
		fi
		rm "${linuxloopsdir}"/cache/"${distribution}".iso*
		return 0
	else
		echo "iso signature verification failed, will not proceed."
		rm "${linuxloopsdir}"/cache/"${distribution}".iso*
	fi
elif [ "${1}" == "lxc" ]; then
	master_key=E7FB0CAEC8173D669066514CBAEFF88C22F6E216
	cur_speed=0; for lxcserver in https://sgp1lxdmirror01.do.letsbuildthe.cloud https://sfo3lxdmirror01.do.letsbuildthe.cloud https://fra1lxdmirror01.do.letsbuildthe.cloud; do if ! avg_speed=$(curl -4fsSL -m 5 -r 0-1048576 -w '%{speed_download}' -o /dev/null --url "${lxcserver}/images" 2> /dev/null); then avg_speed=0; fi; echo Download speed rating for mirror ${lxcserver} is ${avg_speed}; if [ ${avg_speed} -gt ${cur_speed} ]; then cur_speed=${avg_speed}; lxc_mirror=${lxcserver}; fi; done; echo Using mirror ${lxc_mirror}
	available_builds=$(curl -Ls ${lxc_mirror}/images/"${2}"/"${3}"/amd64/"${4}"/ | tr '>' '\n' | grep '<a href' | cut -d '=' -f2 | cut -d'"' -f2 | cut -d'/' -f1 | sort -r)
	for build in ${available_builds}; do
		if [ "${build}" == "" ] || [ "${build}" == ".." ] || ! curl -L --output /dev/null --silent --head --fail ${lxc_mirror}/images/"${2}"/"${3}"/amd64/"${4}"/"${build}"/rootfs.tar.xz; then continue; fi
		echo "Downloading lxc rootfs checksum"
		rm -f "${linuxloopsdir}"/cache/"${2}"-SHA256SUMS
		sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f ${lxc_mirror}/images/"${2}"/"${3}"/amd64/"${4}"/"${build}"/SHA256SUMS -o "${linuxloopsdir}"/cache/"${2}"-SHA256SUMS
		if [ -f "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz ] && [ -f "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz.asc ] && [ "$(sha256sum ${linuxloopsdir}/cache/${2}-rootfs.tar.xz | cut -d' ' -f1)" == "$(cat ${linuxloopsdir}/cache/${2}-SHA256SUMS | grep rootfs.tar.xz | cut -d' ' -f1)" ]; then
			if [ -z "$(command -v gpg)" ] || [ -z "$(command -v dirmngr)" ] || [ -z "${master_key}" ]; then skip_gpg=1; fi
			if ([ ${skip_gpg} -eq 1 ] || sudo -u ${SUDO_USER} gpg --homedir "${linuxloopsdir}"/gnupg --verify "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz.asc "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz) && tar xf "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz -C "${bootstrapdir}"; then
				echo "Using cached lxc rootfs."
				rm -f "${linuxloopsdir}"/cache/"${2}"-SHA256SUMS
				return 0
			fi
		fi
		rm -f "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz*
		echo "Downloading lxc rootfs image from ${lxc_mirror}/images/${2}/${3}/amd64/${4}/${build}/rootfs.tar.xz..."
		if ! sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f ${lxc_mirror}/images/"${2}"/"${3}"/amd64/"${4}"/"${build}"/rootfs.tar.xz -o "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz; then if [ "${install_type}" == "image" ]; then losetup -d "${destination_device}"; fi; exit_with_error "Download of ${2} lxc image from ${lxc_mirror}/images/${2}/${3}/amd64/${4}/${build}/rootfs.tar.xz failed."; fi
		echo "Verifying lxc rootfs checksum"
		if [ "$(sha256sum ${linuxloopsdir}/cache/${2}-rootfs.tar.xz | cut -d' ' -f1)" == "$(cat ${linuxloopsdir}/cache/${2}-SHA256SUMS | grep rootfs.tar.xz | cut -d' ' -f1)" ]; then
			if [ -z "$(command -v gpg)" ] || [ -z "$(command -v dirmngr)" ]; then
				echo "Warning: lxc rootfs cannot be verified as gpg is not available."
				skip_gpg=1
			elif [ -z "${master_key}" ]; then
				echo "Warning: lxc rootfs cannot be verified as no master key provided."
				skip_gpg=1
			else
				echo "Importing lxc master key"
				sudo -u ${SUDO_USER} gpg --homedir "${linuxloopsdir}"/gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv "${master_key}"
				echo "Downloading lxc rootfs signature"
				sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f ${lxc_mirror}/images/"${2}"/"${3}"/amd64/"${4}"/"${build}"/rootfs.tar.xz.asc -o "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz.asc
				echo "Verifying lxc rootfs signature"
			fi
			if [ ${skip_gpg} -eq 1 ] || sudo -u ${SUDO_USER} gpg --homedir "${linuxloopsdir}"/gnupg --verify "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz.asc "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz; then
				if tar xf "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz -C "${bootstrapdir}"; then
					echo "lxc rootfs successfylly extracted."
					rm -f "${linuxloopsdir}"/cache/"${2}"-SHA256SUMS
					return 0
				else
					echo "Failed to extract lxc rootfs, trying next image."
				fi
			else
				echo "signature verification failed, trying next image."
			fi
		else
			echo "sha256sum verification failed, trying next image."
		fi
		rm -f "${linuxloopsdir}"/cache/"${2}"-rootfs.tar.xz* "${linuxloopsdir}"/cache/"${2}"-SHA256SUMS
	done
elif [ "${1}" == "rootfs-xz" ]; then
	echo "Downloading rootfs image checksum"
	rm -f "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum*
	sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f ${rootfs_sha256sum} -o "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum
	if [ "${distribution}" == "OpenSUSE" ]; then
		sudo -u ${SUDO_USER} sed "s@ opensuse.*@${linuxloopsdir}/cache/${distribution}-rootfs.tar.xz@g" "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum > "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum.mod
	else
		sudo -u ${SUDO_USER} sed "s@$(basename ${2})@${linuxloopsdir}/cache/${distribution}-rootfs.tar.xz@g" "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum > "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum.mod
	fi
	if [ -f "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz ] && [ -f "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.asc ] && sha256sum -c "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum.mod; then
		if [ -z "$(command -v gpg)" ] || [ -z "$(command -v dirmngr)" ] || [ -z "${master_key}" ]; then skip_gpg=1; fi
		if ([ ${skip_gpg} -eq 1 ] || sudo -u ${SUDO_USER} gpg --homedir "${linuxloopsdir}"/gnupg --verify "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.asc "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz"${gpg_check_extension}") && tar xf "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz -C "${bootstrapdir}"; then
			echo "Using cached xz rootfs."
			rm -f "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum*
			return 0	
		fi
	fi
	rm -f "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz{,.asc}
	echo "Downloading ${distribution} rootfs image from ${2}"
	for i in 1 .. 3; do
		if sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f "${2}" -o "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz; then
			if sha256sum -c "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum.mod; then
				echo "sha256sum verification succeeded"
				break
			else
				echo "sha256sum verification failed, retrying download..."
			fi
		fi
		if [ "${i}" -eq 3 ]; then if [ "${install_type}" == "image" ]; then losetup -d "${destination_device}"; fi; exit_with_error "Download of ${distribution} rootfs from ${2} failed"; fi
	done
	if [ -z "$(command -v gpg)" ] || [ -z "$(command -v dirmngr)" ]; then
		echo "Warning: rootfs cannot be verified as gpg is not available."
		skip_gpg=1
	elif [ -z "${rootfs_signature}" ] || [ -z "${master_key}" ]; then
		echo "Warning: rootfs cannot be verified as no signature or master key provided."
		skip_gpg=1
	else
		echo "Importing master key"
		sudo -u ${SUDO_USER} gpg --homedir "${linuxloopsdir}"/gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv "${master_key}"
		echo "Downloading rootfs signature"
		sudo -u ${SUDO_USER} curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f ${rootfs_signature} -o "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.asc
		echo "Verifying rootfs signature"
	fi
	if [ ${skip_gpg} -eq 1 ] || sudo -u ${SUDO_USER} gpg --homedir "${linuxloopsdir}"/gnupg --verify "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.asc "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz"${gpg_check_extension}"; then
		if tar xf "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz -C "${bootstrapdir}"; then
			echo "${distribution} rootfs successfylly extracted."
			rm -f "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz.sha256sum*
			return 0
		else
			echo "Failed to extract ${distribution} rootfs, will not proceed."
		fi
	else
		echo "rootfs signature verification failed, will not proceed."
	fi
	rm "${linuxloopsdir}"/cache/"${distribution}"-rootfs.tar.xz*
fi
if [ "${install_type}" == "image" ]; then losetup -d "${destination_device}"; fi
exit_with_error "Download of bootstrap image failed."
}

bootstrap()
{
return_value=0
if [ "${systemd_init}" == "Yes" ]; then
	if [ ! -z "${brunch}" ] || [ ! -z "${chromeos}" ]; then
		mkdir -p /usr/local/tmp/linuxloops
		chown 1000:1000 /usr/local/tmp /usr/local/tmp/linuxloops
		homebinddir="$(sudo -u ${SUDO_USER} mktemp -d /usr/local/tmp/linuxloops/linuxloops.XXXXXXXX)"
		bootstrapdir="${homebinddir}/bootstrap"
	else
		bootstrapdir="$(mktemp -d /tmp/linuxloops.XXXXXXXX)/bootstrap"
		homebinddir="${linuxloopsdir}/tmp/$(echo ${bootstrapdir} | cut -d'/' -f3)"
	fi
	chrootdir="${bootstrapdir}"/mnt
	trap 'end_bootstrap; clear -x; echo "Installation cancelled by INT or TERM signal."; exit 1' INT TERM
	mkdir -p "${bootstrapdir}"
	sudo -u ${SUDO_USER} mkdir -p "${homebinddir}"
	mount --bind "${homebinddir}" "${homebinddir}"
	mount --make-slave "${homebinddir}"
	mount --bind "${homebinddir}" "${bootstrapdir}"
	mount --make-slave "${bootstrapdir}"
	if ! mountpoint -q "${bootstrapdir}" || ! mountpoint -q "${homebinddir}" ; then echo "Linuxloops systemd init working directories could not be mounted."; exit 1; fi
else
	if [ ! -z "${brunch}" ] || [ ! -z "${chromeos}" ]; then
		mkdir -p /usr/local/tmp/linuxloops
		chown 1000:1000 /usr/local/tmp /usr/local/tmp/linuxloops
		homebinddir="$(sudo -u ${SUDO_USER} mktemp -d /usr/local/tmp/linuxloops/linuxloops.XXXXXXXX)"
		bootstrapdir="${homebinddir}/bootstrap"
	else
		homebinddir="$(sudo -u ${SUDO_USER} mktemp -d ${linuxloopsdir}/tmp/linuxloops.XXXXXXXX)"
		bootstrapdir="${homebinddir}/bootstrap"
	fi
	chrootdir="${bootstrapdir}"/mnt
	trap 'end_bootstrap; clear -x; echo "Installation cancelled by INT or TERM signal."; exit 1' INT TERM
	sudo -u ${SUDO_USER} mkdir -p "${bootstrapdir}"
	mount --bind "${homebinddir}" "${homebinddir}"
	mount --make-slave "${homebinddir}"
	mount --bind "${bootstrapdir}" "${bootstrapdir}"
	mount --make-slave "${bootstrapdir}"
	if ! mountpoint -q "${bootstrapdir}" || ! mountpoint -q "${homebinddir}" ; then echo "Linuxloops systemd init working directories could not be mounted."; exit 1; fi
fi
download_bootstrap ${bootstrap}
if [ "${distribution}" == "FoxFlake" ] || [ "${distribution}" == "GLF-OS" ] || [ "${distribution}" == "NixOS" ]; then
	mount --bind "${homebinddir}" "${chrootdir}"
	if ! mountpoint -q "${chrootdir}" ; then echo "NixOS specific working directory could not be mounted."; exit 1; fi
fi
mount -t proc none "${bootstrapdir}"/proc
mount --bind /sys "${bootstrapdir}"/sys
mount --make-slave "${bootstrapdir}"/sys
if mountpoint -q /sys/firmware/efi/efivars; then
	mount --bind /sys/firmware/efi/efivars "${bootstrapdir}"/sys/firmware/efi/efivars
	mount --make-slave "${bootstrapdir}"/sys/firmware/efi/efivars
fi
mount --bind /dev "${bootstrapdir}"/dev
mount --make-slave "${bootstrapdir}"/dev
mount --bind /dev/pts "${bootstrapdir}"/dev/pts
mount --make-slave "${bootstrapdir}"/dev/pts
mount -t tmpfs -o mode=1777 none "${bootstrapdir}"/dev/shm
mount -t tmpfs none "${bootstrapdir}"/run
mount -t tmpfs -o mode=1777 none "${bootstrapdir}"/tmp
mkdir -p "${bootstrapdir}"/tmp/linuxloops
if [ ! -z "${brunch}" ] || [ ! -z "${chromeos}" ]; then
	mount -t ramfs -o mode=1777,exec,symfollow none "${bootstrapdir}"/tmp/linuxloops
else
	mount -t tmpfs -o mode=1777,exec,symfollow none "${bootstrapdir}"/tmp/linuxloops
fi
if [ -f /etc/hostname ]; then
    cp /etc/hostname "${bootstrapdir}"/etc/hostname
else
    echo "bootstrap" > "${bootstrapdir}"/etc/hostname
fi
cp /etc/hosts "${bootstrapdir}"/etc/hosts
rm -f "${bootstrapdir}"/etc/resolv.conf
cp /etc/resolv.conf "${bootstrapdir}"/etc/resolv.conf
chroot_"${chroot_function}" || (return_value=1 && return)
generate_bootstrap_init
generate_partition_script
generate_setup_and_mount_rootfs
generate_mount_efi
generare_enter_chroot
generate_install_settings
generate_install_secureboot
generate_install_surface
generate_install_nvidia
generate_install_fstab
generate_install_initramfs
generate_install_swap
generate_install_bootloader
generate_cleanup
generate_install_live
generate_efi_entry
generate_exit_chroot
chroot "${bootstrapdir}" /tmp/linuxloops/bootstrap_init || return_value=1
rm -f "${bootstrapdir}"/tmp/linuxloops/setup_and_mount_rootfs
if ([ ! -z "${github}" ] && [ "${distribution}" == "Bazzite" ]) || ([ ! -z "${github}" ] && [ "${distribution}" == "Fedora-Atomic" ]); then exit 0; fi
if [ "${return_value}" -eq 0 ]; then
	generare_install_userpw
	generate_selinux_fix
	if [ -x "${bootstrapdir}"/tmp/linuxloops/install_userpw ]; then
		chroot "${bootstrapdir}" /tmp/linuxloops/install_userpw || return_value=1
		rm -f "${bootstrapdir}"/tmp/linuxloops/install_userpw "${chrootdir}"/tmp/linuxloops/set_userpw
	fi
	if [ "${install_type}" == "image" ] && [ -f "${chrootdir}"/etc/secureboot_key/MOK.der ]; then
		cp "${chrootdir}"/etc/secureboot_key/MOK.der "${fullpath}".der
		chown ${SUDO_UID}:$(id -g ${SUDO_UID}) "${fullpath}".der
	fi
fi
if [ -x "${bootstrapdir}"/tmp/linuxloops/exit_chroot ]; then chroot "${bootstrapdir}" /tmp/linuxloops/exit_chroot || return_value=1; fi
end_bootstrap
trap '' INT TERM
}

set_packages_locale()
{
if [ "$(echo ${locale} | cut -d'_' -f1)" == "C" ]; then
	packages_locale="en"
else
	packages_locale="$(echo ${locale} | cut -d'_' -f1)"
fi
}

start_install()
{
set_packages_locale
if [ "${install_type}" == "disk" ]; then
	for i in ls "${fullpath}"?*; do
		umount ${i} > /dev/null 2>&1
		ret="${?}"
		if [ ! "${ret}" -eq 0 ] && [ ! "${ret}" -eq 32 ]; then exit_with_error "Automatic unmounting of partitions failed with error ${ret}. Please unmount all device partitions manually and try again."; fi
	done
	destination_device="${fullpath}"
	if (expr match "${fullpath}" ".*[0-9]$" >/dev/null); then
		partition_path="${destination_device}"p
	else
		partition_path="${destination_device}"
	fi
	
else
	echo "Creating image file ${fullpath}..."
	rm -f "${fullpath}" "${fullpath}".der "${fullpath}".grub.txt
	echo -n > "${fullpath}"
	if [ "x$(df -T "${fullpath}" | tail -1 | cut -d' ' -f2)" == "xbtrfs" ]; then chattr +C "${fullpath}"; chattr -c "${fullpath}"; fi
	if [ "${live}" == "Yes" ]; then
		dd if=/dev/zero of="${fullpath}" bs=1M count=${install_sizeMB} status=progress
	else
		dd if=/dev/zero of="${fullpath}" bs=1M count=0 seek=${install_sizeMB} status=none
	fi
	chown ${SUDO_UID}:$(id -g ${SUDO_UID}) "${fullpath}"
	destination_device="$(losetup --show -fP "${fullpath}")" || exit_with_error "losetup command failed."
	partition_path="${destination_device}"p
fi
efi_partition="${partition_path}"1
if [ "${distribution}" == "BlissOS" ]; then
	root_partition="${partition_path}"2
else
	boot_partition="${partition_path}"2
	root_partition="${partition_path}"3
fi
bootstrap
return "${return_value}"
}

grub_config()
{
if [ ! -z "${wsl}" ]; then
	img_uuid=$(sudo -u ${SUDO_USER} /mnt/c/Windows/System32/mountvol.exe $(echo ${fullpath:5:1} | tr a-z A-Z): /L | cut -d'{' -f2 | cut -d'}' -f1)
else
	img_uuid=$(blkid -s PARTUUID -o value "$(df "${fullpath}" --output=source | sed 1d)")
fi
img_path=$(if [ "$(findmnt -n -o FSTYPE $(findmnt -n -o TARGET -T ${fullpath}))" == "btrfs" ] && [ ! -b "$(findmnt -n -o SOURCE $(findmnt -n -o TARGET -T ${fullpath}))" ]; then echo "$(findmnt -n -o SOURCE $(findmnt -n -o TARGET -T ${fullpath}) | cut -d"[" -f2 | cut -d"]" -f1)"; fi)$(if [ "$(findmnt -n -o TARGET -T ${fullpath})" == "/" ]; then echo "$(realpath ${fullpath})"; else echo "$(realpath ${fullpath})" | sed "s#$(findmnt -n -o TARGET -T ${fullpath})##g"; fi)
if [ -z "${wsl}" ] && ([ "$(grep -o '^ID=[^,]\+' /etc/os-release | cut -d'=' -f2)" == "debian" ] || [ "$(grep -o '^ID=[^,]\+' /etc/os-release | cut -d'=' -f2)" == "ubuntu" ] || [ "$(grep -o '^ID=[^,]\+' /etc/os-release | cut -d'=' -f2)" == "linuxmint" ] || [ "$(grep -o '^ID=[^,]\+' /etc/os-release | cut -d'=' -f2)" == "fedora" ] || [ "$(grep -o '^ID=[^,]\+' /etc/os-release | cut -d'=' -f2)" == "zorin" ]); then remove_tpm="\n	rmmod tpm"; fi
if [ "${distribution}" == "ChromeOS-Flex" ]; then
config="menuentry '${distribution}' --class '$(echo ${distribution} | tr [:upper:] [:lower:])' {${remove_tpm}
	img_path=\"${img_path}\"
	img_uuid=\"${img_uuid}\"
	search --no-floppy --set=root --file \${img_path}
	loopback loop \${img_path}
	if [ -f (loop,7)/bootimage.cfg ]; then source (loop,7)/bootimage.cfg; else bootimage=A; fi
	linux (loop,12)/syslinux/vmlinuz.\${bootimage} img_uuid=\${img_uuid} img_path=\${img_path} bootimage=\${bootimage} loop.max_part=16 ro quiet splash boot=local noresume noswap loglevel=7 console= cros_efi kvm-intel.vmentry_l1d_flush=always loadpin.enabled=0 loadpin.enforce=0 rootfstype=ramfs ${dev_mode}
	initrd (loop,7)/initramfs.img (loop,7)/firmwares.img (loop,7)/modules.img
}
"

config="menuentry '${label}' --class '${class}' {${remove_tpm}
	img_path=\"${img_path}\"
	img_uuid=\"${img_uuid}\"
	search --no-floppy --set=root --file \"\${img_path}\"
	loopback loop \"\${img_path}\"
	linuxloops_args=\"rdinit=/linuxloops img_path=\${img_path} img_uuid=\${img_uuid}\"
	export linuxloops_args
	configfile (loop,2)$(if [ \"${root_fstype}\" == \"btrfs\" ]; then echo /@boot; fi)/grub$(if [ \"${distribution}\" == \"AlmaLinux\" ] || [ \"${distribution}\" == \"Bazzite\" ] || [ \"${distribution}\" == \"Fedora\" ] || [ \"${distribution}\" == \"Fedora-Atomic\" ] || [ \"${distribution}\" == \"Nobara\" ] || [ \"${distribution}\" == \"OpenSUSE\" ] || [ \"${distribution}\" == \"Qubes\" ] || [ \"${distribution}\" == \"RockyLinux\" ]; then echo 2; fi)/grub.cfg
}
"
fi
echo -e "${config}" > "${fullpath}".grub.txt
chown ${SUDO_UID}:$(id -g ${SUDO_UID}) "${fullpath}".grub.txt
if [ ! -z "${chromeos}" ]; then
	mkdir -p /mnt/stateful_partition/unencrypted/linuxloops_config/tmp
	source=$(blkid --match-token PARTLABEL=EFI-SYSTEM | head -1 | cut -d':' -f1)
	mount "${source}" /mnt/stateful_partition/unencrypted/linuxloops_config/tmp
	rm -rf /mnt/stateful_partition/unencrypted/linuxloops_config/tmp/efi/boot
	mkdir -p /mnt/stateful_partition/unencrypted/linuxloops_config/tmp/efi/boot
	curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/sebanc/brunch-unstable/raw/continuous-integration/efi-partition/efi/boot/grubx64.efi -o /mnt/stateful_partition/unencrypted/linuxloops_config/tmp/efi/boot/bootx64.efi
	echo -e "set timeout=5\n"> /mnt/stateful_partition/unencrypted/linuxloops_config/tmp/efi/boot/grub.cfg
	echo -e "${config}" >> /mnt/stateful_partition/unencrypted/linuxloops_config/tmp/efi/boot/grub.cfg
	umount /mnt/stateful_partition/unencrypted/linuxloops_config/tmp
fi
}

set_mirror()
{
case "${1}" in
	"AlmaLinux")
		if ! curl -sfLo/dev/null -r0-0 "${2}/$(echo ${almalinux_version} | tr A-Z a-z)/BaseOS/x86_64/os/repodata/repomd.xml"; then return 1; fi
		mirror_AlmaLinux="${2}"
	;;
	"Arch")
		if ! curl -sfLo/dev/null -r0-0 "${2}/core/os/x86_64/core.db"; then return 1; fi
		mirror_Arch="${2}"
	;;
	"Artix")
		if ! curl -sfLo/dev/null -r0-0 "${2}/system/os/x86_64/system.db"; then return 1; fi
		mirror_Artix="${2}"
	;;
	"BlendOS")
		if ! curl -sfLo/dev/null -r0-0 "${2}/breakfast.db"; then return 1; fi
		mirror_BlendOS="${2}"
	;;
	"CachyOS")
		if ! curl -sfLo/dev/null -r0-0 "${2}/x86_64/cachyos/cachyos.db"; then return 1; fi
		mirror_CachyOS="${2}"
	;;
	"Debian")
		if ! curl -sfLo/dev/null -r0-0 "${2}/dists/$(echo ${debian_version} | tr A-Z a-z)/Release"; then return 1; fi
		mirror_Debian="${2}"
	;;
	"Devuan")
		if ! curl -sfLo/dev/null -r0-0 "${2}/merged/dists/$(echo ${devuan_version} | tr A-Z a-z)/Release"; then return 1; fi
		mirror_Devuan="${2}"
	;;
	"Fedora")
		if ! curl -sfLo/dev/null -r0-0 "${2}/updates/$(echo ${fedora_version} | tr A-Z a-z)/Everything/x86_64/repodata/repomd.xml"; then return 1; fi
		mirror_Fedora="${2}"
	;;
	"Fedora-Atomic")
		if ! curl -sfLo/dev/null -r0-0 "${2}/config"; then return 1; fi
		mirror_Fedora_Atomic="${2}"
	;;
	"Gentoo")
		if ! curl -sfLo/dev/null -r0-0 "${2}/releases/amd64/binpackages/23.0/x86-64/Packages"; then return 1; fi
		mirror_Gentoo="${2}"
	;;
	"Kali")
		if ! curl -sfLo/dev/null -r0-0 "${2}/dists/kali-$(echo ${kali_version} | tr A-Z a-z)/Release"; then return 1; fi
		mirror_Kali="${2}"
	;;
	"Linuxmint")
		if ! curl -sfLo/dev/null -r0-0 "${2}/dists/$(echo ${linuxmint_version} | tr A-Z a-z)/Release"; then return 1; fi
		mirror_Linuxmint="${2}"
	;;
	"Manjaro")
		if ! curl -sfLo/dev/null -r0-0 "${2}/$(echo ${manjaro_version} | tr A-Z a-z)/core/x86_64/core.db"; then return 1; fi
		mirror_Manjaro="${2}"
	;;
	"MX")
		if ! curl -sfLo/dev/null -r0-0 "${2}/mx/repo/dists/$(echo ${debian_version} | tr A-Z a-z)/Release"; then return 1; fi
		mirror_MX="${2}"
	;;
	"Neon")
		if ! curl -sfLo/dev/null -r0-0 "${2}/$(echo ${neon_version} | tr A-Z a-z)/dists/$(echo ${ubuntu_version} | tr A-Z a-z)/Release"; then return 1; fi
		mirror_Neon="${2}"
	;;
	"OpenSUSE")
		if ! curl -sfLo/dev/null -r0-0 "${2}/$(echo ${opensuse_version} | tr A-Z a-z)/repo/oss/INDEX.gz"; then return 1; fi
		mirror_OpenSUSE="${2}"
	;;
	"Parrot")
		if ! curl -sfLo/dev/null -r0-0 "${2}/dists/$(echo ${parrot_version} | tr A-Z a-z)/Release"; then return 1; fi
		mirror_Parrot="${2}"
	;;
	"PikaOS")
		if ! curl -sfLo/dev/null -r0-0 "${2}/dists/pika/Release"; then return 1; fi
		mirror_PikaOS="${2}"
	;;
	"RockyLinux")
		if ! curl -sfLo/dev/null -r0-0 "${2}/$(echo ${rockylinux_version} | tr A-Z a-z)/BaseOS/x86_64/os/repodata/repomd.xml"; then return 1; fi
		mirror_RockyLinux="${2}"
	;;
	"SteamOS")
		if ! curl -sfLo/dev/null -r0-0 "${2}/core-$(echo ${steamos_version} | tr A-Z a-z)/os/x86_64/core-$(echo ${steamos_version} | tr A-Z a-z).db"; then return 1; fi
		mirror_SteamOS="${2}"
	;;
	"Ubuntu")
		if ! curl -sfLo/dev/null -r0-0 "${2}/dists/$(echo ${ubuntu_version} | tr A-Z a-z)/Release"; then return 1; fi
		mirror_Ubuntu="${2}"
	;;
	"Void")
		if ! curl -sfLo/dev/null -r0-0 "${2}/$(echo ${void_version} | tr A-Z a-z)/x86_64-repodata"; then return 1; fi
		mirror_Void="${2}"
	;;
	*)
		exit_with_error "\"${1}\" mirror is not supported for this distribution, supported mirrors are: \"${mirrors_supported[@]}\"."
	;;
esac
}

list_array()
{
if [ "${1}" == "available_distributions" ]; then for distribution in "${available_distributions[@]}"; do echo -e "${distribution}"; done; fi
if [ "${1}" == "available_versions" ]; then for version in "${available_versions[@]}"; do echo -e "${version}"; done; fi
if [ "${1}" == "available_environments" ]; then for environment in "${available_environments[@]}"; do echo -e "${environment}"; done ; fi
if [ "${1}" == "available_locales" ]; then for i in "${!available_locales[@]}"; do if [ "${available_locales[$i]}" == "TRUE" ] || [ "${available_locales[$i]}" == "FALSE" ]; then echo "${available_locales[$i+1]}"; fi; done; fi
if [ "${1}" == "available_keymaps" ]; then for i in "${!available_keymaps[@]}"; do if [ "${available_keymaps[$i]}" == "TRUE" ] || [ "${available_keymaps[$i]}" == "FALSE" ]; then echo "${available_keymaps[$i+1]}"; fi; done; fi
if [ "${1}" == "available_timezones" ]; then for i in "${!available_timezones[@]}"; do if [ "${available_timezones[$i]}" == "TRUE" ] || [ "${available_timezones[$i]}" == "FALSE" ]; then echo "${available_timezones[$i+1]}"; fi; done; fi
if [ "${1}" == "mirrors_supported" ]; then for repository in "${mirrors_supported[@]}"; do echo -e "\"${repository}\""; done; fi
if [ "${1}" == "all" ]; then
	for distribution in "${available_distributions[@]}"; do
		distribution_parameters
		echo -en "Distribution: ${distribution}"
		for version in "${available_versions[@]}"; do
			distribution_version_parameters
			echo -en "\n\tVersion: ${version}"
			echo -en "\n\t\tAvailable environments: "
			for environment in "${available_environments[@]}"; do
				echo -en "${environment} "
			done
			echo -en "\n\t\tInstall on btrfs filesystem possible: ${btrfs_supported}"
			echo -en "\n\t\tNvidia proprietary driver installation possible: ${nvidia_supported}"
			echo -en "\n\t\tSurface patches installation possible: ${surface_supported}"
			echo -en "\n\t\tCustom mirrors supported: ${mirrors_supported[@]}"
		done
	echo -e '\n'
	done
fi
}

check_home_space()
{
find "${linuxloopsdir}"/cache/* -type f -mtime +7 -exec rm {} \; 2>/dev/null
for removedir in "${linuxloopsdir}"/tmp/*; do if [ -d "${removedir}" ] && ! mountpoint -q "${removedir}"; then rm -rf "${removedir}"; fi; done
if [ ! -z "${brunch}" ] || [ ! -z "${chromeos}" ]; then for removedir in /usr/local/tmp/linuxloops/*; do if [ -d "${removedir}" ] && ! mountpoint -q "${removedir}"; then rm -rf "${removedir}"; fi; done; fi
case "${distribution}" in
	'Bazzite')
		available_space_needed=4
	;;
	'BlissOS')
		available_space_needed=3
	;;
	'Brunch')
		available_space_needed=7
	;;
	'ChromeOS-Flex')
		available_space_needed=7
	;;
	'Fedora-Atomic')
		available_space_needed=4
	;;
	'Qubes')
		available_space_needed=7
	;;
	'Tails')
		available_space_needed=4
	;;
	*)
		available_space_needed=1
	;;
esac
}

possible_image_size()
{
if [ -f "${destination}" ]; then freed_space=$(( $(du "${destination}" | cut -d'	' -f1) / 1024 / 1024 )); else freed_space=0; fi
if [ "$(df --output=source -- ${linuxloopsdir} | sed 1d)" == "$(df --output=source -- $(echo $(realpath ${destination}) | sed 's![^/]*$!!') | sed 1d)" ]; then bootstrap_space=${available_space_needed}; else bootstrap_space=0; fi
maximum_image_size=$(( ($(df -k --output=avail $(echo $(realpath ${destination}) | sed 's![^/]*$!!') | sed 1d) / 1024 / 1024) + ${freed_space} - ${bootstrap_space} ))
}

get_extra_partitions_attribute()
{
if [ "${1}" == "mountpoint" ]; then echo $(echo ${extra_partitions[${2}]} | cut -d'*' -f1); fi
if [ "${1}" == "name" ]; then echo $(echo ${extra_partitions[${2}]} | cut -d'*' -f2); fi
if [ "${1}" == "fstype" ]; then echo $(echo ${extra_partitions[${2}]} | cut -d'*' -f3); fi
if [ "${1}" == "mountoptions" ]; then
	if [ "$(get_extra_partitions_attribute fstype ${2})" == "btrfs" ]; then
		extra_partition_mount_options="defaults,subvol=@$(echo $(get_extra_partitions_attribute mountpoint ${2}) | sed 's@/@@g')"
	else
		extra_partition_mount_options="defaults"
	fi
	if [ "$(echo ${extra_partitions[${2}]} | cut -d'*' -f4)" != "" ]; then extra_partition_mount_options="${extra_partition_mount_options},$(echo ${extra_partitions[${2}]} | cut -d'*' -f4)"; fi
	echo ${extra_partition_mount_options}
fi
if [ "${1}" == "size" ]; then echo $(echo ${extra_partitions[${2}]} | cut -d'*' -f5); fi
if [ "${1}" == "encryption" ]; then echo $(echo ${extra_partitions[${2}]} | cut -d'*' -f6); fi
if [ "${1}" == "isencryptionused" ]; then
	encryption_used="No"
	if [ ${#extra_partitions[@]} -ne 0 ]; then
		for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
			if [ "$(get_extra_partitions_attribute encryption ${i})" == "Yes" ]; then encryption_used="Yes"; fi
		done
	fi
	echo ${encryption_used}
fi
if [ "${1}" == "totalsize" ]; then
	extra_partitions_size=0
	if [ ${#extra_partitions[@]} -ne 0 ]; then
		for i in $(seq 0 $(( ${#extra_partitions[@]} - 1 ))); do
			if [ ! -z $(get_extra_partitions_attribute size ${i}) ]; then extra_partitions_size=$(( ${extra_partitions_size} + $(get_extra_partitions_attribute size ${i}) )); fi
		done
	fi
	echo ${extra_partitions_size}
fi
}

compute_partitions()
{
if [ ! -z "${efi_name}" ]; then
	if ! echo "${efi_name}" | grep -Eq '[a-zA-Z0-9_-]$'; then echo "Name provided for EFI partition is invalid."; exit 1; fi
else
	efi_name="EFI"
fi
if [ ! -z "${boot_name}" ]; then
	if ! echo "${boot_name}" | grep -Eq '[a-zA-Z0-9_-]$'; then echo "Name provided for Boot partition is invalid."; exit 1; fi
else
	boot_name="Boot"
fi
if [ ! -z "${root_name}" ]; then
	if ! echo "${root_name}" | grep -Eq '[a-zA-Z0-9_-]$'; then echo "Name provided for Root partition is invalid."; exit 1; fi
else
	root_name="Root"
fi
if [ ! -z "${efi_mountoptions}" ]; then
	if ! echo "${efi_mountoptions}" | grep -Eq '[a-zA-Z0-9,:=.-]$'; then echo "Mountoptions provided for EFI partition is invalid."; exit 1; fi
fi
if [ ! -z "${boot_mountoptions}" ]; then
	if ! echo "${boot_mountoptions}" | grep -Eq '[a-zA-Z0-9,:=.-]$'; then echo "Mountoptions provided for Boot partition is invalid."; exit 1; fi
fi
if [ ! -z "${root_mountoptions}" ]; then
	if ! echo "${root_mountoptions}" | grep -Eq '[a-zA-Z0-9,:=.-]$'; then echo "Mountoptions provided for Root partition is invalid."; exit 1; fi
fi
default_mount_option="defaults"
if [ ! -z "${efi_mountoptions}" ]; then final_efi_mountoptions="${default_mount_option},${efi_mountoptions}"; else final_efi_mountoptions="${default_mount_option}"; fi
if [ "${root_fstype}" == "btrfs" ]; then
	if [ ! -z "${boot_mountoptions}" ]; then final_boot_mountoptions="${default_mount_option},${boot_mountoptions},subvol=@boot"; else final_boot_mountoptions="${default_mount_option},subvol=@boot"; fi
	if  [ "${root_compression}" == "Yes" ]; then compression_mountoptions=",compress=zstd"; fi
	if [ ! -z "${root_mountoptions}" ]; then
		final_root_mountoptions="${default_mount_option},subvol=@${compression_mountoptions},${root_mountoptions}"
		final_home_subvol_mountoptions="${default_mount_option},subvol=@home${compression_mountoptions},${root_mountoptions}"
	else
		final_root_mountoptions="${default_mount_option},subvol=@${compression_mountoptions}"
		final_home_subvol_mountoptions="${default_mount_option},subvol=@home${compression_mountoptions}"
	fi
	final_swap_subvol_mountoptions="${default_mount_option},subvol=@swap"
else
	if [ ! -z "${boot_mountoptions}" ]; then final_boot_mountoptions="${default_mount_option},${boot_mountoptions}"; else final_boot_mountoptions="${default_mount_option}"; fi
	if [ ! -z "${root_mountoptions}" ]; then final_root_mountoptions="${default_mount_option},${root_mountoptions},errors=remount-ro"; else final_root_mountoptions="${default_mount_option},errors=remount-ro"; fi
fi
if [ "${partition4}" == "*****No" ] || [ "${partition4}" == "*****Yes" ]; then partition4=""; fi
if [ "${partition5}" == "*****No" ] || [ "${partition5}" == "*****Yes" ]; then partition5=""; fi
if [ "${partition6}" == "*****No" ] || [ "${partition6}" == "*****Yes" ]; then partition6=""; fi
if [ "${partition7}" == "*****No" ] || [ "${partition7}" == "*****Yes" ]; then partition7=""; fi
if [ "${partition8}" == "*****No" ] || [ "${partition8}" == "*****Yes" ]; then partition8=""; fi
extra_partitions=("${partition4}" "${partition5}" "${partition6}" "${partition7}" "${partition8}")
i=4
while [ ${i} -ge 0 ]; do
	if [ "${extra_partitions[${i}]}" == "" ]; then
		unset extra_partitions[${i}]
		i=$(( ${i} - 1 ))
		continue
	fi
	if [ $(echo "${extra_partitions[${i}]}" | grep -o '*' | grep -c .) -ne 5 ]; then echo "Format of extra partition $(( ${i} + 1 )) is incorrect."; exit 1; fi
	if [ -z "$(echo ${extra_partitions[${i}]} | cut -d'*' -f1)" ]; then echo "Mountpoint was not provided for partition extra partition $(( ${i} + 1 ))."; exit 1; fi
	if ! echo "${extra_partitions[${i}]}" | cut -d'*' -f1 | grep -Eq '/[a-zA-Z0-9_/-]*$'; then echo "Mountpoint provided for extra partition $(( ${i} + 1 )) is not valid: $(echo "${extra_partitions[${i}]}" | cut -d'*' -f1)."; exit 1; fi
	extra_partitions[${i}]="$(echo $(realpath -m $(echo ${extra_partitions[${i}]} | cut -d'*' -f1)))*$(echo ${extra_partitions[${i}]} | cut -d'*' -f2-)"
	for j in / /bin /boot /boot/efi /etc /nix /nix/store /sbin /usr /usr/bin /usr/lib /usr/lib/x86_64-linux-gnu /usr/lib64 /usr/sbin /var /var/lib /var/lib/nixos /var/log; do if [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f1)" == "${j}" ]; then echo "The following mounpoints are not supported: /, /bin, /boot, /boot/efi, /etc, /nix, /nix/store, /sbin, /usr, /usr/bin, /usr/lib, /usr/lib/x86_64-linux-gnu, /usr/lib64, /usr/sbin, /var, /var/lib, /var/lib/nixos, /var/log"; exit 1; fi; done
	for j in {0..4}; do if [ ${j} -ne ${i} ] && [ ! -z "$(echo ${extra_partitions[${i}]} | cut -d'*' -f1)" ]; then if [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f1)" == "$(echo ${extra_partitions[${j}]} | cut -d'*' -f1)" ]; then echo "The mounpoint $(echo ${extra_partitions[${i}]} | cut -d'*' -f1) defined several times."; exit 1; fi; fi; done
	if [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f1)" == "/home" ]; then separate_home="Yes"; fi
	if [ -z "$(echo ${extra_partitions[${i}]} | cut -d'*' -f2)" ]; then echo "Name was not provided for extra partition $(( ${i} + 1 ))."; exit 1; fi
	if ! echo "${extra_partitions[${i}]}" | cut -d'*' -f2 | grep -Eq '[a-zA-Z0-9_-]*$'; then echo "Name provided for extra partition $(( ${i} + 1 )) is not valid: $(echo "${extra_partitions[${i}]}" | cut -d'*' -f2)."; exit 1; fi
	if [ -z "$(echo ${extra_partitions[${i}]} | cut -d'*' -f3)" ]; then echo "FS type was not provided for extra partition $(( ${i} + 1 ))."; exit 1; fi
	if [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f3)" != "ext4" ] && [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f3)" != "btrfs" ]; then echo "FS type should be ext4 or btrfs: $(echo ${extra_partitions[${i}]} | cut -d'*' -f3)"; exit 1; fi
	if [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f3)" == "btrfs" ] && [ ! "${btrfs_supported}" == "Yes" ]; then echo "Filesystem type btrfs is not supported for this distribution version."; exit 1; fi
	if [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f4)" != "" ] && ! echo "${extra_partitions[${i}]}" | cut -d'*' -f4 | grep -Eq '[a-zA-Z0-9,:=.-]*$'; then echo "Mountoptions provided for extra partition $(( ${i} + 1 )) are not valid: $(echo "${extra_partitions[${i}]}" | cut -d'*' -f4)."; exit 1; fi
	if [ -z "$(echo ${extra_partitions[${i}]} | cut -d'*' -f5)" ]; then echo "Size was not provided for extra partition $(( ${i} + 1 ))."; exit 1; fi
	if ! echo "${extra_partitions[${i}]}" | cut -d'*' -f5 | grep -Eq '[!0-9]$' || [ $(echo ${extra_partitions[${i}]} | cut -d'*' -f5) -lt 0 ]; then echo "Size is not a positive integer for extra partition $(( ${i} + 1 )): $(echo ${extra_partitions[${i}]} | cut -d'*' -f5)"; fi
	if [ -z "$(echo ${extra_partitions[${i}]} | cut -d'*' -f6)" ]; then echo "Encryption was not provided for extra partition $(( ${i} + 1 ))."; exit 1; fi
	if [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f6)" != "Yes" ] && [ "$(echo ${extra_partitions[${i}]} | cut -d'*' -f6)" != "No" ]; then echo "Encryption should be Yes or No: $(echo ${extra_partitions[${i}]} | cut -d'*' -f3)"; exit 1; fi
	i=$(( ${i} - 1 ))
done
extra_partitions=( $(echo "${extra_partitions[@]}" | sed 's@ @\n@g' | sort -t "|" -k 1,1) )
if [ -z "${root_size}" ] || [ ${install_size} -eq $(( 1 + ${root_size} + $(get_extra_partitions_attribute totalsize) )) ]; then
	root_size=$(( ${install_size} - 1 - $(get_extra_partitions_attribute totalsize) ))
	root_sizeMB=$(( ${install_sizeMB} - 1024 - $(get_extra_partitions_attribute totalsize) * 1024 ))
else
	root_sizeMB=$(( ${root_size} * 1024 ))
fi
if [ ! "${live}" == "Yes" ] && [ "${root_sizeMB}" -lt $(( 12 * 1024 )) ]; then echo "Rootfs size cannot be lower than 12 GB."; exit 1; fi
}

generate_declarative_config()
{
rm -f "${generate_config}"
cat >"${generate_config}" <<DECLARATIVE_CONFIG
# Linuxloops generated config file
# If you intend to share this config, make sure to clear the options that are specific to your personal choices (destination, install_size, user account name, passwords and options)

# Main parameters
distribution="${distribution}"
version="${version}"
environment="${environment}"

# Parameters obtained interactively if not provided
destination="${destination}"
install_size="${install_size}"
useraccount_name="${useraccount_name}"
useraccount_password=""
encryption_password=""

# Optional parameters
useraccount_autologin="${useraccount_autologin}"
user_password_for_encryption="${user_password_for_encryption}"
hostname="${hostname}"
locale="${locale}"
keymap="${keymap}"
timezone="${timezone}"
grub_hide="${grub_hide}"
nvidia="${nvidia}"
surface="${surface}"
kernel_parameters="${kernel_parameters}"

# Optional partitioning parameters
# By default linuxloops create a standard setup with 3 partitions (EFI, Boot and Root)
# Additional partitions can be added by defining partition4 to partition8 variables in the format "<Mountpoint>*<Name>*<FS Type>*<Mountoptions>*<Size in GB>*<Encryption>"
efi_name="${efi_name}"
efi_mountoptions="${efi_mountoptions}"
boot_name="${boot_name}"
boot_mountoptions="${boot_mountoptions}"
root_name="${root_name}"
root_fstype="${root_fstype}"
root_mountoptions="${root_mountoptions}"
root_encryption="${root_encryption}"
partition4="${partition4}"
partition5="${partition5}"
partition6="${partition6}"
partition7="${partition7}"
partition8="${partition8}"
# Swap:A swap file of the defined size will be created on the rootfs (Swap is not mandatory but a minimum of 4 GB is generally recommended or 1.5 times the amount of RAM if you intend to use hibernation)
swap_size=${swap_size}

# List of additional packages to install (default: "")
custom_packages="${custom_packages}"

# Script that will be executed as root at the end of the install process (default: "").
# Make sure to escape special characters inside the "custom_commands" variable, notably double quotes and dollar signs (for variables that should be interpreted inside the target install).
custom_commands="${custom_commands}"

DECLARATIVE_CONFIG
chown ${SUDO_USER}:$(id -g ${SUDO_UID}) "${generate_config}"
}

gui_create_env()
{
if [ -f ./linuxloops_gui.py ] || [ ! -f "${linuxloopsdir}"/gui/linuxloops_gui.py ] || [ ! -f "${linuxloopsdir}"/gui/linuxloops.sha256sum ] || [ "$(sha256sum ${0} | cut -d' ' -f1)" != "$(cat ${linuxloopsdir}/gui/linuxloops.sha256sum)" ]; then
	echo "Creating the GUI python environment, please wait..."
	rm -rf "${linuxloopsdir}"/gui
	sudo -u ${SUDO_USER} mkdir -p "${linuxloopsdir}"/gui &&
	(if [ -f ./linuxloops_gui.py ]; then
		sudo -u ${SUDO_USER} cp ./linuxloops_gui.py "${linuxloopsdir}"/gui/linuxloops_gui.py
	else
		cat >"${linuxloopsdir}"/gui/linuxloops_gui.py <<'LINUXLOOPS_GUI'
import argparse
import os
import re
import subprocess
import sys
import webview

"""
Linuxloops GUI app made with pywebview.
"""

parser = argparse.ArgumentParser()
parser.add_argument('-t', '--title', required=True, help="Window title")
parser.add_argument('-m', '--menu', required=True, help="Menu to display")
parser.add_argument('-p', '--parameters', required=False, help="Parameters to use")
parser.add_argument('-q', '--question', required=False, help="Question to display")
parser.add_argument('-w', '--writepid', required=False, help="Write pid to file")
args = parser.parse_args()

html = """
<!DOCTYPE html>
<html>
<head lang="en">
<meta charset="UTF-8">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/purecss@3.0.0/build/pure-min.css" integrity="sha384-X38yfunGUhNzHpBaEBsWLO+A0HDYOQi8ufWDkZ0k9e0eXz/tH3II7uKZ9msv++Ls" crossorigin="anonymous">
<style>
body {
    background: #ffffff;
    color: #555555;
    font-family: Ubuntu, "times new roman", times, roman, serif;
    text-align: center;
}

table, th, tr, td {
    box-sizing: border-box;
    margin-bottom: 0px !important;
    margin-top: 0px !important;
    padding-bottom: 0px !important;
    padding-top: 0px !important;
    text-align: center;
}

th, tr, td {
    margin-left: 0px !important;
    margin-right: 0px !important;
    padding-left: 5px !important;
    padding-right: 5px !important;
    width: auto;
}

input:disabled, select:disabled {
     color: #bbbbbb;
}

input:not(:disabled), select:not(:disabled) {
     border: 2px solid lightgrey;
     color: #555555;
}

.containing-table {
    left: 0;
    right: 0;
    margin-left: auto;
    margin-right: auto;
    padding: 10px;
    display: none;
    width: fit-content;
    max-height: 320px;
    overflow: auto;
    border: 1px dotted blue;
    text-align: left;
}

.center {
   width: 100%;
   text-align: center;
}

.round {
  border-radius: 10%;
  width: 150px;
}

.tooltip {
  position: relative;
  display: inline-block;
  border-bottom: 1px dotted black; /* If you want dots under the hoverable text */
}

.tooltip .tooltiptext {
  display: none;
  width: 300px;
  background-color: grey;
  color: #fff;
  text-align: center;
  padding: 5px 0;
  border-radius: 6px;
  padding-left: 5px;
  padding-right: 5px;
  position: absolute;
  z-index: 1;
  bottom: 100%;
  margin-left: -60px;
}

.tooltip:hover .tooltiptext {
  display: inline-flex;
}

.progress-bar {
  height: 4px;
  background-color: rgba(5, 114, 206, 0.2);
  width: 80%;
  overflow: hidden;
  margin: auto;
}

.progress-bar-value {
  width: 100%;
  height: 100%;
  background-color: rgb(5, 114, 206);
  animation: indeterminateAnimation 1s infinite linear;
  transform-origin: 0% 50%;
}

@keyframes indeterminateAnimation {
  0% {
    transform:  translateX(0) scaleX(0);
  }
  40% {
    transform:  translateX(0) scaleX(0.4);
  }
  100% {
    transform:  translateX(100%) scaleX(0.5);
  }
}
</style>
</head>
<body>
<span align="center"><h1><img style="vertical-align: middle; margin-right: 15px" src="https://github.com/sebanc/linuxloops/raw/main/linuxloops.png" width="64px" alt="Logo"/>Linuxloops</h1></span>
<hr style="border-top: 1px solid #bbbbbb;">
"""
if args.menu == "radiofirst":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">Exit</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.destroy()
    }

    function select() {
        const radioButtons = document.querySelectorAll('input[name="radio"]')
            for (const radioButton of radioButtons) {
                if (radioButton.checked) {
                    radio = radioButton.value
                    break
                }
            }
        pywebview.api.selected(radio)
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_radio().then(showResponse)
    })
</script>
"""
elif args.menu == "radio":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.selected("return")
    }

    function select() {
        const radioButtons = document.querySelectorAll('input[name="radio"]')
            for (const radioButton of radioButtons) {
                if (radioButton.checked) {
                    radio = radioButton.value
                    break
                }
            }
        pywebview.api.selected(radio)
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_radio().then(showResponse)
    })
</script>
"""
elif args.menu == "range":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.selected("return")
    }

    function select() {
        pywebview.api.selected(document.getElementById('installsize').value)
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_range().then(showResponse)
    })
</script>
"""
elif args.menu == "disk":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.selected("return")
    }

    function select() {
        const radioButtons = document.querySelectorAll('input[name="radio"]')
            for (const radioButton of radioButtons) {
                if (radioButton.checked) {
                    radio = radioButton.id
                    break
                }
            }
        pywebview.api.selected(radio)
    }
    
    function refresh_drives() {
        pywebview.api.selected("refresh")
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_disk().then(showResponse)
    })
</script>
"""
elif args.menu == "image":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.selected("return")
    }

    function create_image_file() {
        pywebview.api.save_image()
    }

    function select() {
        if (document.getElementById("image_path").value == "") {
            alert("Please select the image file path before continuing.")
        } else {
            pywebview.api.selected(document.getElementById("image_path").value)
        }
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_image().then(showResponse)
    })
</script>
"""
elif args.menu == "partitioning":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }

    function exit() {
        pywebview.api.selected("return")
    }

    function select() {
        const radioButtons = document.querySelectorAll('input[name="radio"]')
            for (const radioButton of radioButtons) {
                if (radioButton.checked) {
                    radio = radioButton.value
                    break
                }
            }
        pywebview.api.selected(document.getElementById('swapsize').value + '^' + radio)
    }

    function custom_partitioning() {
        pywebview.api.selected('custom')
    }
    
    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_partitioning().then(showResponse)
    })
</script>
"""
elif args.menu == "partitions":
        html += """
<br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.selected("return")
    }

    function verify(result) {
        if (result == "ko") { alert(thiserror); thiselement.value = "" }
    }

    function isValidName(element) {
        thiselement = element
        thiserror = "Invalid partition name format (should match the regex '[a-zA-Z0-9_-]*$')"
        regex = '[a-zA-Z0-9_-]*$'
        pywebview.api.regex_match(element.value, regex).then(verify)
    }
    
    function isValidMountpoint(element) {
        if (element.value == "") { return }
        i = element.value.length
        while (i > 1) { if (element.value.substring(i - 1, i) == "/" && element.value.substring(i - 2, i - 1) == "/") { element.value = element.value.substring(0, i - 2) + element.value.substring(i-1, element.value.length) }; i = i - 1 }
        if (element.value != "/" && element.value.substring(element.value.length - 1, element.value.length) == "/") { element.value = element.value.substring(0, element.value.length - 1) }
        switch(element.value) {
            case '/':
            case '/bin':
            case '/boot':
            case '/boot/efi':
            case '/etc':
            case '/nix':
            case '/nix/store':
            case '/sbin':
            case '/usr':
            case '/usr/bin':
            case '/usr/lib':
            case '/usr/lib/x86_64-linux-gnu':
            case '/usr/lib64':
            case '/usr/sbin':
            case '/var':
            case '/var/lib':
            case '/var/lib/nixos':
            case '/var/log':
                alert("The following mounpoints are not supported: /, /bin, /boot, /boot/efi, /etc, /nix, /nix/store, /sbin, /usr, /usr/bin, /usr/lib, /usr/lib/x86_64-linux-gnu, /usr/lib64, /usr/sbin, /var, /var/lib, /var/lib/nixos, /var/log")
                element.value = ""
                return
        }
        for (i = 3; i < 8; i++) {
            if (element != document.getElementById('mountpoint' + i) && document.getElementById('mountpoint' + i).value && element.value == document.getElementById('mountpoint' + i).value) {
                alert("The mounpoint " + element.value + " is already defined.")
                element.value = ""
                return
            }
        }
        thiselement = element
        thiserror = "Invalid partition mountpoint format (should match the regex '/[a-zA-Z0-9_/-]*$')"
        regex = '/[a-zA-Z0-9_/-]*$'
        pywebview.api.regex_match(element.value, regex).then(verify)
    }

    function isValidMountoptions(element) {
        thiselement = element
        thiserror = "Invalid partition mountoptions format (should match the regex '[a-zA-Z0-9,:=.-]*$')"
        regex = '[a-zA-Z0-9,:=.-]*$'
        pywebview.api.regex_match(element.value, regex).then(verify)
    }

    function checkSize(element, disksize, maxswap) {
        if (document.getElementById('size2').value && document.getElementById('size2').value < 12) { element.value=12; alert('Root partition size should be at least 12 GB.') }
        else if (element.value && element.value < 0) { element.value=""; alert('Partition size should be a positive integer') }
        totalsize = 1
        for (i = 2; i < 8; i++) { if (document.getElementById('size' + i).value) { totalsize = totalsize + Number(document.getElementById('size' + i).value) } }
        if (totalsize > disksize) { totalsize = totalsize - element.value; element.value = ""; alert('Total partitions size cannot exceed the remaining size of ' + disksize + ' GB.') }
        document.getElementById('remaining').innerHTML = disksize - totalsize
        possible_swap = document.getElementById('size2').value - 10
        if (possible_swap > maxswap) { possible_swap = maxswap }
        document.getElementById('range').max = possible_swap
        if (document.getElementById('swapsize').value > possible_swap) { document.getElementById('swapsize').value = possible_swap }
    }

    function select() {
        partitions = ''
        for (i = 0; i < 8; i++) {
            if (document.getElementById('mountpoint' + i).value != "" || document.getElementById('name' + i).value != "" || document.getElementById('fstype' + i).value != "" || document.getElementById('size' + i).value != "") {
                if (document.getElementById('mountpoint' + i).value == "") { alert("Mountpoint not provided for partition " + i + "."); return }
                if (document.getElementById('name' + i).value == "") { alert("Name not provided for partition " + i + "."); return }
                if (document.getElementById('fstype' + i).value == "") { alert("Filesystem type not selected for partition " + i + "."); return }
                if (document.getElementById('size' + i).value == "") { alert("Size not provided for partition " + i + "."); return }
            }
            encryption = []
            if (document.getElementById('encryption' + i).checked) {
                encryption[i] = "Yes"
            } else {
                encryption[i] = "No"
            }
            if (i == 0) { partitions = partitions + document.getElementById("mountoptions" + i).value + '^' }
            else if (i == 1) { partitions = partitions + document.getElementById("name" + i).value + '^' + document.getElementById("mountoptions" + i).value + '^' }
            else if (i == 2) { partitions = partitions + document.getElementById("name" + i).value + '^' + document.getElementById("fstype" + i).value + '^' + document.getElementById("mountoptions" + i).value + '^' + document.getElementById("size" + i).value + '^' + encryption[i] + '^' }
            else { partitions = partitions + document.getElementById("mountpoint" + i).value + '^' + document.getElementById("name" + i).value + '^' + document.getElementById("fstype" + i).value + '^' + document.getElementById("mountoptions" + i).value + '^' + document.getElementById("size" + i).value + '^' + encryption[i] + '^' }
        }
        pywebview.api.selected(document.getElementById('swapsize').value + '^' + partitions)
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.generate_partitions_table().then(showResponse)
    })
</script>
"""
elif args.menu == "user":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.selected("return")
    }

    function verify(result) {
        if (result == "ko") { alert(thiserror); thiselement.value = "" }
    }

    function isValidUsername(element) {
        thiselement = element
        thiserror = "Invalid Username (username can only contain lowercase and numerical characters)."
        regex = '^[a-z][-a-z0-9]*$'
        pywebview.api.regex_match(element.value, regex).then(verify)
    }

    function isValidPassword(element) {
        thiselement = element
        thiserror = "Invalid character in password (passwords cannot contain the ^ character)."
        regex = '[^^^]*$'
        pywebview.api.regex_match(element.value, regex).then(verify)
    }

    function isValidPasswordVerification(element) {
        if (document.getElementById("user_password").value == "" || document.getElementById("user_password").value != element.value) { alert("Verification password does not match."); element.value = "" }
    }
    
    function display_encryption_password() {
        if (document.getElementById("encryption_auto").checked) { document.getElementById("encryption_box").style.display = "none" }
        else { document.getElementById("encryption_box").style.display = "block" }
    }

    function select() {
        username=document.getElementById("username").value
        user_password=document.getElementById("user_password").value
        user_password_verification=document.getElementById("user_password_verification").value
        if (document.getElementById("encryption_password")) { encryption_password=document.getElementById("encryption_password").value } else { encryption_password="" }
        if (document.getElementById("encryption_password_verification")) { encryption_password_verification=document.getElementById("encryption_password_verification").value } else { encryption_password_verification="" }
        password_two=document.getElementById("user_password_verification").value
        if (document.getElementById("autologin") && document.getElementById("autologin").checked) { autologin = "Yes" } else { autologin = "No" }
        if (document.getElementById("encryption_auto") && document.getElementById("encryption_auto").checked) { encryption_auto = "Yes" } else { encryption_auto = "No" }
        pywebview.api.selected(username + '^' + user_password + '^' + user_password_verification + '^' + autologin + '^' + encryption_auto + '^' + encryption_password + '^' + encryption_password_verification)
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_user().then(showResponse)
    })
</script>
"""
elif args.menu == "parameters":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.selected("return")
    }

    function select() {
        language=document.getElementById("language").value
        keymap=document.getElementById("keymap").value
        timezone=document.getElementById("timezone").value
        pywebview.api.selected(language + '^' + keymap + '^' + timezone)
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_parameters().then(showResponse)
    })
</script>
"""
elif args.menu == "customizations":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div style="position: fixed; bottom: 15px; left: 15px;"><a onclick="exit()" href="#" class="pure-button round">&laquo; Previous</a></div>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="select()" href="#" class="pure-button pure-button-primary round">Next &raquo;</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.selected("return")
    }

    function open_custom_file() {
        pywebview.api.open_custom_file()
    }

    function select() {
        if (document.getElementById("hostname")) { hostname = document.getElementById("hostname").value }
	if (document.getElementById("nvidia") && document.getElementById("hide_grub").checked) { hide_grub = "Yes" } else { hide_grub = "No" }
        if (document.getElementById("nvidia") && document.getElementById("nvidia").checked) { nvidia = "Yes" } else { nvidia = "No" }
        if (document.getElementById("surface") && document.getElementById("surface").checked) { surface = "Yes" } else { surface = "No" }
        if (document.getElementById("custom_packages")) { custom_packages = document.getElementById("custom_packages").value }
        if (document.getElementById("custom_script")) { custom_script = document.getElementById("custom_script").value }
        if (document.getElementById("kernel_parameters")) { kernel_parameters = document.getElementById("kernel_parameters").value }
        if (document.querySelectorAll('input[name="mirror"]')) {
            const mirrors = document.querySelectorAll('input[name="mirror"]')
            mirrorlist = ''
            for (const mirror of mirrors) {
                mirrorlist = mirrorlist + mirror.value + '^'
            }
            pywebview.api.selected(hostname + '^' + hide_grub + '^' + nvidia + '^' + surface + '^' + custom_packages + '^' + custom_script + '^' + kernel_parameters + '^' + mirrorlist)
        }
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
        pywebview.api.generate_customizations().then(showResponse)
    })
</script>
"""
elif args.menu == "progress":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div class="containing-table" id="response-container"></div>
<div class="center" style="margin-top: 100px;">
  <div class="progress-bar">
    <div class="progress-bar-value"></div>
  </div>
</div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
    })
</script>
"""
        if args.writepid:
            pidfile = open(args.writepid, 'w')
            pidfile.write(str(os.getpid()))
            pidfile.close()
elif args.menu == "finished":
        html += """
<div id='title' style="margin-top: 30px;"></div><br>
<div style="position: fixed; bottom: 15px; right: 15px;"><a onclick="exit()" href="#" class="pure-button pure-button-primary round">Exit</a></div>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }

    function copy_configuration() {
        document.getElementById('configuration').select()
        document.execCommand("copy");
    }
    
    function exit() {
        pywebview.api.destroy()
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
    })
</script>
"""
elif args.menu == "messagebox":
        html = """
<!DOCTYPE html>
<html>
<head lang="en">
<meta charset="UTF-8">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/purecss@3.0.0/build/pure-min.css" integrity="sha384-X38yfunGUhNzHpBaEBsWLO+A0HDYOQi8ufWDkZ0k9e0eXz/tH3II7uKZ9msv++Ls" crossorigin="anonymous">
<link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Ubuntu:regular,bold&subset=Latin">
<body>
<div style="display: flex; height: 100px; width: 100%;">
    <img src="https://cdn.pixabay.com/photo/2015/06/09/16/12/error-803716_1280.png" style="height: 80px; margin-top: auto; margin-bottom: auto;">
    <div id='title' style="text-align: center; margin-left: 30px; margin-right: 30px; margin-top: auto; margin-bottom: auto; width: 500px;"></div>
</div>
<div style="width: 100%; text-align: center;"><a onclick="exit()" href="#" class="pure-button">Ok</a></span>
<script>
    function showText(text) {
        document.getElementById('title').innerHTML = text
    }
    
    function exit() {
        pywebview.api.destroy()
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.add_text().then(showText)
    })
</script>
"""
else:
        if args.menu != "confirmation" and args.menu != "file-select" and args.menu != "file-open" and args.menu != "jsalert":
            print("Please select a menu to display.")
            sys.exit()
html += """
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</body>
</html>
"""

class linuxloops:
    def add_text(self):
        innerhtml = args.question
        return innerhtml
    def regex_match(self, path, regex):
        p = re.compile(regex)
        m = p.fullmatch(path)
        if m is not None:
            return "ok"
        else:
            return "ko"
    def generate_radio(self):
        listargs=args.parameters.split('^')
        innerhtml = ''
        for i in listargs:
            innerhtml += '<label for="' + i + '" class="pure-radio" style="margin-right: 50px;"><input type="radio" id="' + i + '" name="radio" value="' + i + '"/> ' + i.replace('_', ' ') + '</label><br>'
        return innerhtml
    def generate_range(self):
        listargs=args.parameters.split('^')
        innerhtml = '<div class="center"><input type="range" id="range" name="range" step="1" min="' + listargs[0] + '" value="' + listargs[1] + '" max="' + listargs[2] + '" oninput="installsize.value=range.value" style="width: 400px"><br><input type="text" id="installsize" value="' + listargs[1] + '" style="width: 50px; text-align: center;" disabled></div>'
        return innerhtml
    def generate_disk(self):
        listargs = args.parameters.split('^')
        innerhtml = '<table class="pure-table center"><thead style="vertical-align: middle;"><tr><th style="padding: 5px !important;">Select</th><th style="padding: 5px !important;">Drive ID</th><th style="padding: 5px !important;">Drive size</th><th style="padding: 5px !important;">Drive name</th></tr></thead><tbody>'
        for i in listargs:
            disk = i.split('|')
            innerhtml += '<tr><td style="padding: 5px !important;"><input type="radio" class="pure-radio" name="radio" id="' + disk[0] + '" /></td><td style="padding: 5px !important;">' + disk[0] + '</td><td style="padding: 5px !important;">' + disk[1] + '</td><td style="padding: 5px !important;">' + disk[2] + '</td></tr>'
        innerhtml += '</tbody></table><br><a onclick="refresh_drives()" href="#" class="pure-button center">Refresh drives list</a>'
        return innerhtml
    def generate_image(self):
        innerhtml = '<a onclick="create_image_file()" href="#" class="pure-button">Create image file</a><input type="text" id="image_path" value="" style="margin-left: 10px; width: 300px;" disabled>'
        return innerhtml
    def generate_partitioning(self):
        listargs=args.parameters.split('^')
        innerhtml = '<div class="center" style="margin-bottom: 10px;">Select a standard partitioning option:</div>'
        i = 0
        while i < len(listargs):
            if i == 0:
                if int(listargs[i]) < 64:
                    swap_max = listargs[i]
                else:
                    swap_max = "64"
            else:
                innerhtml += '<label for="' + listargs[i] + '" class="pure-radio" style="margin-right: 20px; margin-bottom: 5px;"><input type="radio" id="' + listargs[i] + '" name="radio" value="' + listargs[i] + '"/> ' + listargs[i] + '</label><br>'
            i += 1
        innerhtml += '<div class="center" style="margin-top: 5px;"><div class="tooltip">Swap size:<div class="tooltiptext">A swap file of the defined size will be created on the rootfs (Swap is not mandatory but a minimum of 4 GB is generally recommended or 1.5 times the amount of RAM if you intend to use hibernation)</div></div>&nbsp&nbsp&nbsp<input type="range" id="range" name="range" step="1" min="0" value="0" max="' + swap_max + '" oninput="swapsize.value=range.value";" style="width: 200px; vertical-align: middle;">&nbsp&nbsp&nbsp<input type="text" id="swapsize" value="0" style="width: 50px; text-align: center;" disabled>&nbspGB</div><br><br>'
        innerhtml += '<div class="center"><div style="margin-bottom: 10px;">Or define a custom partitioning:</div><a onclick="custom_partitioning()" href="#" class="pure-button">Custom partitioning</a></div>'
        return innerhtml
    def generate_partitions_table(self):
        listargs=args.parameters.split('^')
        total_size=int(listargs[0])
        if listargs[1] == 'No':
            btrfs_supported=" disabled"
        else:
            btrfs_supported=""
        if total_size < 64:
            swap_max = total_size - 10
        else:
            swap_max = 64
        innerhtml = '<div class="center" style="margin-bottom: 10px;">Available space for the installation:&nbsp<span style="font-weight: bold;">' + str(total_size) + '</span> GB / Remaining space to allocate:&nbsp<span id="remaining" style="font-weight: bold;">0</span> GB</div><table class="pure-table center"><colgroup><col span="1"><col span="1" style="width: 100px;"><col span="1" style="width: 100px;"><col span="1"><col span="1" style="width: 180px;"><col span="1" style="width: 130px;"></colgroup><thead style="font-size: 14px; vertical-align: middle;"><tr><th>Partition<br>#</th><th>Mountpoint</th><th>Name</th><th>Filesystem<br>type</th><th>Specific mount options<br>(comma-separated list)</th><th>Size</th><th>Encryption</th></tr></thead><tbody>'
        for x in range(8):
            if x == 0:
                btrfs_hidden=btrfs_supported
                btrfs_selected=""
                ext4_hidden=""
                ext4_selected=""
                fat32_hidden=""
                fat32_selected=" selected"
                fstype_disabled=" disabled"
                size_disabled=" disabled"
                size="0.125"
                mountpoint_disabled=" disabled"
                mountpoint="/boot/efi"
                encryption_disabled=" disabled"
                mountoptions_disabled=""
                partition_name="EFI"
                partition_name_disabled=" disabled"
            elif x == 1:
                btrfs_hidden=btrfs_supported
                btrfs_selected=""
                ext4_hidden=""
                ext4_selected=" selected"
                fat32_hidden=" disabled"
                fat32_selected=""
                fstype_disabled=" disabled"
                size_disabled=" disabled"
                size="0.875"
                mountpoint_disabled=" disabled"
                mountpoint="/boot"
                encryption_disabled=" disabled"
                mountoptions_disabled=""
                partition_name="Boot"
                partition_name_disabled=""
            elif x == 2:
                btrfs_hidden=btrfs_supported
                btrfs_selected=""
                ext4_hidden=""
                ext4_selected=" selected"
                fat32_hidden=" disabled"
                fat32_selected=""
                fstype_disabled=""
                size_disabled=""
                size=str(total_size - 1)
                mountpoint_disabled=" disabled"
                mountpoint="/"
                encryption_disabled=""
                mountoptions_disabled=""
                partition_name="Root"
                partition_name_disabled=""
            else:
                btrfs_hidden=btrfs_supported
                btrfs_selected=""
                ext4_hidden=""
                ext4_selected=""
                fat32_hidden=" disabled"
                fat32_selected=""
                fstype_disabled=""
                fstype=""
                size_disabled=""
                size=""
                mountpoint_disabled=""
                mountpoint=""
                encryption_disabled=""
                mountoptions_disabled=""
                partition_name=""
                partition_name_disabled=""
            innerhtml += '<tr><td>' + str(x + 1) + '</td><td><input type="text" id="mountpoint' + str(x) + '" class="pure-u-1 pure-u-md-1-3 center" style="width: 90px;" onchange="isValidMountpoint(this)" value="' + mountpoint + '"' + mountpoint_disabled + '/></td><td><input type="text" id="name' + str(x) + '" class="pure-u-1 pure-u-md-1-3 center" value="' + partition_name + '" style="width: 80px;" onchange="isValidName(this)"' + partition_name_disabled + '/></td><td><select id="fstype' + str(x) + '" style="height: 24px;"' + fstype_disabled + '/><option></option><option' + fat32_selected + fat32_hidden + '>fat32</option><option' + ext4_selected + ext4_hidden + '>ext4</option><option' + btrfs_selected + btrfs_hidden + '>btrfs</option></select></td><td><input type="text" id="mountoptions' + str(x) + '" class="pure-u-1 pure-u-md-1-3 center" style="width: 160px;" onchange="isValidMountoptions(this)" value=""' + mountoptions_disabled + '/></td><td><input type="number" class="pure-u-1 pure-u-md-1-3 center" style="width: 80px" min="0" onchange="checkSize(this, ' + str(total_size) + ', ' + str(swap_max) + ')" name="size" id="size' + str(x) + '" value="' + size + '"' + size_disabled + '/><span style="vertical-align: bottom;">&nbspGB</span></td><td><input type="checkbox" id="encryption' + str(x) + '" class="pure-checkbox center"' + encryption_disabled + '/></td></tr>'
        innerhtml += '</tbody></table><div class="center" style="margin-top: 5px;"><div class="tooltip">Swap size:<div class="tooltiptext">A swap file of the defined size will be created on the rootfs (Swap is not mandatory but a minimum of 4 GB is generally recommended or 1.5 times the amount of RAM if you intend to use hibernation)</div></div>&nbsp&nbsp&nbsp<input type="range" id="range" name="range" step="1" min="0" value="0" max="' + str(swap_max) + '" oninput="swapsize.value=range.value" style="width: 200px; vertical-align: middle;">&nbsp&nbsp&nbsp<input type="text" id="swapsize" value="0" style="width: 50px; text-align: center;" disabled>&nbspGB</div>'
        return innerhtml
    def generate_user(self):
        listargs=args.parameters.split('^')
        if listargs[1] == 'Yes':
            password_field = 'Encryption password:'
        else:
            password_field = 'User password:'
        innerhtml = ''
        innerhtml += '<div style="width: 300px; display: inline-block;">Username:</div><input type="text" id="username" name="username" style="width: 200px; margin-left: 10px;" onchange="isValidUsername(this)"/>'
        innerhtml += '<br><br><div style="width: 300px; display: inline-block;">User password:</div><input type="password" id="user_password" name="user_password" style="width: 200px; margin-left: 10px;" onchange="isValidPassword(this)"/>'
        innerhtml += '<br><br><div style="width: 300px; display: inline-block;">Confirm user password:</div><input type="password" id="user_password_verification" name="user_password_verification" style="width: 200px; margin-left: 10px;" onchange="isValidPasswordVerification(this)"/>'
        if listargs[0] != 'None':
            innerhtml += '<br><br><div style="width: 300px; display: inline-block;">Enable user autologin:</div><input align="center" type="checkbox" id="autologin" name="autologin" style="width: 200px; margin-left: 10px;"/>'
        if listargs[1] == 'Yes':
            innerhtml += '<br><br><div style="width: 300px; display: inline-block;">Use user password for encryption:</div><input align="center" type="checkbox" id="encryption_auto" name="autologin" style="width: 200px; margin-left: 10px;" onclick="display_encryption_password();" checked/>'
            innerhtml += '<span style="display: none;" id="encryption_box">'
            innerhtml += '<br><div style="width: 300px; display: inline-block;">Encryption password:</div><input type="password" id="encryption_password" name="encryption_password" style="width: 200px; margin-left: 10px;"/>'
            innerhtml += '<br><br><div style="width: 300px; display: inline-block;">Confirm encryption password:</div><input type="password" id="encryption_password_verification" name="encryption_password_verification" style="width: 200px; margin-left: 10px;"/>'
            innerhtml += '</span>'
        return innerhtml
    def generate_parameters(self):
        listargs=args.parameters.split('^')
        languages=listargs[0].split(';')
        keymaps=listargs[2].split(';')
        timezones=listargs[4].split(';')
        innerhtml = '<div class="center">Language selection:<br><select id="language" style="padding: 0">'
        for x in languages:
            language_code=x.split(" ")
            if language_code[0] == listargs[1]:
                innerhtml += '<option value="' + x + '" selected>' + x + '</option>'
            else:
                innerhtml += '<option value="' + x + '">' + x + '</option>'
        innerhtml += '</select><br>'
        innerhtml += '<br>Keyboard configuration:<br><select id="keymap" style="padding: 0">'
        for y in keymaps:
            keymap_code=y.split(" ")
            if keymap_code[0] == listargs[3]:
                innerhtml += '<option value="' + y + '" selected>' + y + '</option>'
            else:
                innerhtml += '<option value="' + y + '">' + y + '</option>'
        innerhtml += '</select><br>'
        innerhtml += '<br>Timezone:<br><select id="timezone" style="padding: 0">'
        for z in timezones:
            timezone_code=z.split(" ")
            if timezone_code[0] == listargs[5]:
                innerhtml += '<option value="' + z + '" selected>' + z + '</option>'
            else:
                innerhtml += '<option value="' + z + '">' + z + '</option>'
        innerhtml += '</select></div>'
        return innerhtml
    def generate_customizations(self):
        listargs=args.parameters.split('^')
        global directory
        directory = listargs[4]
        innerhtml = '<table><tbody>'
        if listargs[0] != '':
            innerhtml += '<tr><td style="width: 250px; height: 30px;">Hostname:</td><td style="width: 400px; height: 30px;"><input type="text" id="hostname" value="' + listargs[0] + '" style="width: 390px;"></td></tr>'
        if listargs[1] != '':
            innerhtml += '<tr><td style="width: 250px; height: 30px;"><label for="hide_grub">Hide GRUB Bootloader</td><td style="width: 400px; height: 30px;"></label><input type="checkbox" id="hide_grub" style="width: 390px;"></td></tr>'
        if listargs[2] != '':
            innerhtml += '<tr><td style="width: 250px; height: 30px;"><label for="nvidia">Install Nvidia proprietary drivers</td><td style="width: 400px; height: 30px;"></label><input type="checkbox" id="nvidia" style="width: 390px;"></td></tr>'
        if listargs[3] != '':
            innerhtml += '<tr><td style="width: 250px; height: 30px;"><label for="surface">Install Microsoft Surface patches</label></td><td style="width: 400px; height: 30px;"><input type="checkbox" id="surface" style="width: 390px;"></td></tr>'
        if listargs[4] != '':
            innerhtml += '<tr><td style="width: 250px; height: 30px;">Custom packages (space-separated list):</td><td style="width: 400px; height: 30px;"><input type="text" id="custom_packages" value="" style="width: 390px;"></td></tr>'
        if listargs[5] != '':
            innerhtml += '<tr><td style="width: 250px; height: 30px;">Apply custom script (at the end of the install process):</td><td style="width: 400px; height: 30px;"><a onclick="open_custom_file()" href="#" class="pure-button" style="height: 25px; width: 80px; vertical-align: middle; padding: 0; margin: 0;">Select file</a><input type="text" id="custom_script" value="" style="margin-left: 10px; width: 300px;" disabled></td></tr>'
        if listargs[6] != '':
            innerhtml += '<tr><td style="width: 250px; height: 30px;">Additional kernel parameters (space-separated list):</td><td style="width: 400px; height: 30px;"><input type="text" id="kernel_parameters" value="" style="width: 390px;"></td></tr>'
        if listargs[7] != '':
            mirrors = listargs[7].split(' ')
            for i in mirrors:
                innerhtml += '<tr><td style="width: 250px; height: 30px;">Use specific ' + i + ' mirror:</td><td style="width: 400px; height: 30px;"><input type="text" name="mirror" id="mirror_' + i + '" value="" style="width: 390px;"></td></tr>'
        innerhtml += '</tbody></table>'
        return innerhtml
    def selected(self, return_value):
        window.destroy()
        print(return_value)
        sys.exit()
    def open_custom_file(self):
        exepath = os.path.dirname(sys.executable) + '/' + os.path.basename(sys.executable)
        result = subprocess.run([exepath, os.path.realpath(__file__), '-m', 'file-open', '-t', 'Custom script selection', '-p', directory], text = True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        listargs=result.stdout.split("'")
        if len(listargs) == 3:
            window.evaluate_js('document.getElementById("custom_script").value = "' + listargs[1] + '"', callback=None)
        else:
            window.evaluate_js('document.getElementById("custom_script").value = ""', callback=None)
    def open_file_dialog(window):
        result = window.create_file_dialog(webview.OPEN_DIALOG, allow_multiple=False, directory=args.parameters)
        window.destroy()
        if result is not None:
            print(result)
        sys.exit()
    def save_image(self):
        exepath = os.path.dirname(sys.executable) + '/' + os.path.basename(sys.executable)
        result = subprocess.run([exepath, os.path.realpath(__file__), '-m', 'file-select', '-t', 'Save image file', '-p', args.parameters], text = True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        listargs=result.stdout.splitlines()
        if len(listargs) == 1:
            window.evaluate_js('document.getElementById("image_path").value = "' + listargs[0] + '"', callback=None)
        else:
            window.evaluate_js('document.getElementById("image_path").value = ""', callback=None)
    def save_file_dialog(window):
        head_tail = os.path.split(args.parameters)
        result = window.create_file_dialog(webview.SAVE_DIALOG, directory=head_tail[0], save_filename=head_tail[1])
        window.destroy()
        if result is not None:
            print(result[0])
        sys.exit()
    def open_confirmation_dialog(window):
        result = window.create_confirmation_dialog('Linuxloops - ' + args.title, args.question)
        window.destroy()
        if result:
            print('Next')
        sys.exit()
    def destroy(self):
        window.destroy()
        sys.exit()

if __name__ == '__main__':
    api = linuxloops()
    if args.menu == "confirmation":
        window = webview.create_window('Linuxloops - ' + args.title, hidden=True, width=800, height=600)
        webview.start(linuxloops.open_confirmation_dialog, window, gui='gtk')
    elif args.menu == "file-select":
        window = webview.create_window('Linuxloops - ' + args.title, hidden=True, width=800, height=600)
        webview.start(linuxloops.save_file_dialog, window, gui='gtk')
    elif args.menu == "jsalert":
        window = webview.create_window('Linuxloops - ' + args.title, html='<html><body><script>alert("' + args.title + ': ' + args.question + '"); window.addEventListener("pywebviewready", function() { pywebview.api.destroy() });</script></body></html>', hidden=True, width=0, height=0)
        webview.start(gui='gtk')
    elif args.menu == "messagebox":
        window = webview.create_window('Linuxloops - ' + args.title, html=html, js_api=api, resizable=False, width=600, height=150)
        webview.start(gui='gtk')
    elif args.menu == "file-open":
        window = webview.create_window('Linuxloops - ' + args.title, hidden=True, width=800, height=600)
        webview.start(linuxloops.open_file_dialog, window, gui='gtk')
    else:
        window = webview.create_window('Linuxloops - ' + args.title, html=html, js_api=api, resizable=False, width=800, height=600)
        webview.start(gui='gtk')
LINUXLOOPS_GUI
chown ${SUDO_USER}:$(id -g ${SUDO_UID}) "${linuxloopsdir}"/gui/linuxloops_gui.py
fi) &&
	sudo -u ${SUDO_USER} bash<<PYTHONBUILD
python3 -m venv --system-site-packages "${linuxloopsdir}"/gui &&
(cd "${linuxloopsdir}"/gui && source ./bin/activate && pip install --upgrade pip pywebview) &&
echo "$(sha256sum ${0} | cut -d' ' -f1)" > "${linuxloopsdir}"/gui/linuxloops.sha256sum
PYTHONBUILD
fi
}

gui_launch()
{
(cd "${linuxloopsdir}"/gui && source ./bin/activate && QTWEBENGINE_DISABLE_SANDBOX=1 WEBKIT_FORCE_SANDBOX=0 WEBKIT_DISABLE_COMPOSITING_MODE=1 python3 linuxloops_gui.py "${@}" 2>/tmp/linuxloops_gui.log)
}

gui_installer()
{
gui_create_env
until false; do
	distribution=$(gui_launch -m radiofirst -t "Distribution selection" -p "$(echo ${available_distributions[@]} | sed 's@ @^@g')" -q "Welcome to the Linuxloops installer. Which distribution do you want to install ?")
	if [ -z "${distribution}" ] || [ "${distribution}" == "return" ]; then exit 1; fi
	check_home_space
	if [ $(( ($(df -k --output=avail "${linuxloopsdir}" | sed 1d) / 1024 / 1024) - ${available_space_needed} )) -lt 0 ]; then
		gui_launch -m messagebox -t "Not enough space in home directory" -q "To install ${distribution} you need ${available_space_needed} GB of available space in your home directory but you only have $(($(df -k --output=avail ${HOME} | sed 1d) / 1024 / 1024)) GB."
		exit 1
	fi
	distribution_parameters
	until false; do
		version=$(gui_launch -m radio -t "Version selection" -p "$(echo ${available_versions_longname[@]} | sed 's@ @^@g')" -q "Which version do you want to install ?" | cut -d'_' -f1)
		if [ -z "${version}" ]; then exit 1; fi
		if [ "${version}" == "return" ]; then break; continue; fi
		distribution_version_parameters
		until false; do
			environment=$(gui_launch -m radio -t "Environment selection" -p "$(echo ${available_environments[@]} | sed 's@ @^@g')" -q "Which environment do you want to install ?")
			if [ -z "${environment}" ]; then exit 1; fi
			if [ "${environment}" == "return" ]; then break; continue; fi
			until false; do
				if [ -z "${wsl}" ]; then install_type=$(gui_launch -m radio -t "Installation type" -p "disk^image" -q "Do you want to install ${distribution} on a disk or in an image file ?"); else install_type="image"; fi
				if [ -z "${install_type}" ]; then exit 1; fi
				if [ "${install_type}" == "return" ]; then break; continue; fi
				until false; do
					if [ "${install_type}" == "disk" ]; then
						local t
						local list
						local device
						local size
						t=0
						list=""
						for i in $(lsblk -drnbpf -o NAME,SIZE); do
							if [ $((t % 2)) == 0 ]; then device=${i}; fi
							if [ $((t % 2)) == 1 ]; then
								size=$((i / 1024 /1024 / 1024))
								if [ ! -z "${device}" ] && [ ! -z "${size}" ] && [ $((size - 14)) -ge 0 ] && ! echo "${device}" | grep -q "/dev/loop" && ! echo ${device} | grep -q $(basename $(realpath "/sys/class/block/$(lsblk -oMOUNTPOINT,PKNAME -rn | grep '/ ' | cut -d' ' -f2)/..")); then
									if [ "${device}" != "/dev/$(lsblk --inverse $(realpath $(df ${0} | grep '^/' | cut -d' ' -f1)) -io NAME | cut -d'-' -f2 | tail -1)" ] && [ -z "$(grep -o 'img_uuid=[^ ,]\+' /proc/cmdline | cut -d'=' -f2)" ] || ([ ! -z "$(grep -o 'img_uuid=[^ ,]\+' /proc/cmdline | cut -d'=' -f2)" ] && [ "${device}" != "/dev/$(lsblk -ndo pkname $(blkid --match-token PARTUUID=$(grep -o 'img_uuid=[^ ,]\+' /proc/cmdline | cut -d'=' -f2) | cut -d':' -f1))" ]); then if [ -z "${list}" ]; then list="${device}|${size}|$(cat /sys/class/block/$(echo ${device} | sed 's@/dev/@@g')/device/model 2>/dev/null) $(cat /sys/class/block/$(echo ${device} | sed 's@/dev/@@g')/device/vendor 2>/dev/null)"; else list="${list}^${device}|${size}|$(cat /sys/class/block/$(echo ${device} | sed 's@/dev/@@g')/device/model 2>/dev/null) $(cat /sys/class/block/$(echo ${device} | sed 's@/dev/@@g')/device/vendor 2>/dev/null)"; fi; fi
								fi
							fi
							t=$((t + 1))
						done
						destination=$(gui_launch -m disk -t "Drive selection" -p "${list}" -q "Select the target drive:" | cut -d' ' -f1)
						if [ -z "${destination}" ]; then exit 1; elif [ "${destination}" == "refresh" ]; then continue; fi
						if [ "${destination}" == "return" ]; then break; continue; fi
						fullpath="${destination}"
						if [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Tails" ]; then
							if [ $(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024 / 1024) - 14 )) -eq 0 ]; then
								install_size=14
							else
								install_size=$(gui_launch -m range -t "Install size selection" -p "14^$(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024 / 1024) ))^$(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024 / 1024) ))" -q "This drive has $(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024 / 1024) )) GB available.<br>How much would you like to allocate for ${distribution} ?")
							fi
						else
							install_size=$(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024 / 1024) ))
						fi
						if [ -z "${install_size}" ]; then exit 1; fi
						if [ "${install_size}" == "return" ]; then continue; fi
						if [ "${install_size}" -eq $(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024 / 1024) )) ]; then install_sizeMB=$(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024) )); else install_sizeMB=$((install_size*1024)); fi
					else
						local path
						if [ ! -z "${wsl}" ]; then
							destination=$(gui_launch -m image -t "Image file creation" -q "Please select the image file path:" -p "/mnt/c/Users/$(echo $(/mnt/c/Windows/System32/cmd.exe /c echo %username% 2> /dev/null) | sed 's/[^a-zA-Z0-9]//g')/${distribution}.img")
						elif [ ! -z "${chromeos}" ] || [ ! -z "${brunch}" ]; then
							destination=$(gui_launch -m image -t "Image file creation" -q "Please select the image file path:" -p "/mnt/stateful_partition/unencrypted/${distribution}.img")
						else
							destination=$(gui_launch -m image -t "Image file creation" -q "Please select the image file path:" -p "$(eval echo ~${SUDO_USER})/${distribution}.img")
						fi
						if [ -z "${destination}" ]; then exit 1; fi
						if [ ! -z "${wsl}" ] && [ "${destination}" == "return" ]; then break 2; continue; elif [ "${destination}" == "return" ]; then break; continue; fi
						if [ "$(echo -n ${destination} | tail -c 4)" != ".img" ]; then destination="${destination}.img"; fi
						if [[ "${destination}" == *"/"* ]] && ([ -z "$(realpath ${destination} 2> /dev/null)" ] || [ ! -d "$(echo $(realpath ${destination}) | sed 's@[^/]*$@@')" ]); then gui_launch -m messagebox -t "Error in image file path selection" -q "Desination path does not exist, please provide an existing path."; continue; fi
						if [ "$(lsblk $(df -h --output=source $(echo $(realpath ${destination}) | sed 's![^/]*$!!') | tail -1) -no TYPE)" == "crypt" ]; then gui_launch -m messagebox -t "Error in image file path selection" -q "Linuxloops disk images cannot be booted from an encrypted partition."; continue; fi
						if [[ ! ${destination} == *"/"* ]]; then path="${PWD}/"; else path="$(realpath ${destination})"; path="$(echo ${path} | sed 's@[^/]*$@@')"; fi
						fullpath="${path}$(basename ${destination})"
						if [ ! -z "${wsl}" ] && [ ! -z "${path##/mnt/*/*}" ]; then gui_launch -m messagebox -t "Error in image file path selection" -q "The ${distribution} disk image has to be installed outside of the WSL VM, please specify a path such as /mnt/\&lt;drive letter\&gt;/..."; continue; fi
						if ([ ! -z "${chromeos}" ] || [ ! -z "${brunch}" ]) && [ ! -z "${path##/mnt/stateful_partition/unencrypted/*}" ]; then gui_launch -m messagebox -t "Error in image file path selection" -q "The ${distribution} disk image has to be installed in the unencrypted data partition, please specify a path such as /mnt/stateful_partition/unencrypted/..."; continue; fi
						possible_image_size
						if [ $(( ${maximum_image_size} - 14 )) -lt 0 ]; then
							gui_launch -m messagebox -t "Error in image file path selection" -q "Not enough space to create the image file, the minimum size is 14 GB. Verify that the path you have selected points to a partition with more than 14 GB available."
							continue
						elif [ $(( ${maximum_image_size} - 14 )) -eq 0 ]; then
							confirmation=$(gui_launch -m confirmation -t "Image file size selection" -q "Exactly 14GB is available on this drive, the installer will proceed with the creation of a 14GB image.")
							if [ -z "${confirmation}" ]; then exit 1; fi
							install_size=14
						else
							install_size=$(gui_launch -m range -t "Image file size selection" -p "14^14^${maximum_image_size}" -q "This partition has ${maximum_image_size} GB available. How much would you like to allocate for ${distribution} ?")
						fi
						if [ -z "${install_size}" ]; then exit 1; fi
						if [ "${install_size}" == "return" ]; then continue; fi
						install_sizeMB=$((install_size*1024))
					fi
					if [ "${distribution}" != "BlissOS" ] && [ "${distribution}" != "Brunch" ] && [ "${distribution}" != "ChromeOS-Flex" ] && [ "${distribution}" != "Tails" ]; then
						until false; do
							if [ "${btrfs_supported}" == "Yes" ]; then
								fsoptions=$(gui_launch -m partitioning -t "Partitioning" -p "$(( ${install_size} - 12 ))^ext4 filesystem^ext4 filesystem with rootfs encryption^btrfs filesystem^btrfs filesystem with rootfs encryption^btrfs filesystem with compression^btrfs filesystem with compression and rootfs encryption")
							else
								fsoptions=$(gui_launch -m partitioning -t "Partitioning" -p "$(( ${install_size} - 12 ))^ext4 filesystem^ext4 filesystem with rootfs encryption")
							fi
							if [ -z "${fsoptions}" ]; then exit 1; fi
							if [ "${fsoptions}" == "return" ]; then break; continue; fi
							if [ "${fsoptions}" == "custom" ]; then
								fsoptions=$(gui_launch -m partitions -t "Custom partitioning" -p "${install_size}^${btrfs_supported}")
								if [ "${fsoptions}" == "" ]; then exit 1; fi
								if [ "${fsoptions}" == "return" ]; then continue; fi
								swap_size=$(echo "${fsoptions}" | cut -d'^' -f1)
								efi_mountoptions=$(echo "${fsoptions}" | cut -d'^' -f2)
								boot_name=$(echo "${fsoptions}" | cut -d'^' -f3)
								boot_mountoptions=$(echo "${fsoptions}" | cut -d'^' -f4)
								root_name=$(echo "${fsoptions}" | cut -d'^' -f5)
								root_fstype=$(echo "${fsoptions}" | cut -d'^' -f6)
								root_mountoptions=$(echo "${fsoptions}" | cut -d'^' -f7)
								root_size=$(echo "${fsoptions}" | cut -d'^' -f8)
								root_encryption=$(echo "${fsoptions}" | cut -d'^' -f9)
								partition4="$(echo "${fsoptions}" | cut -d'^' -f10)*$(echo "${fsoptions}" | cut -d'^' -f11)*$(echo "${fsoptions}" | cut -d'^' -f12)*$(echo "${fsoptions}" | cut -d'^' -f13)*$(echo "${fsoptions}" | cut -d'^' -f14)*$(echo "${fsoptions}" | cut -d'^' -f15)"
								partition5="$(echo "${fsoptions}" | cut -d'^' -f16)*$(echo "${fsoptions}" | cut -d'^' -f17)*$(echo "${fsoptions}" | cut -d'^' -f18)*$(echo "${fsoptions}" | cut -d'^' -f19)*$(echo "${fsoptions}" | cut -d'^' -f20)*$(echo "${fsoptions}" | cut -d'^' -f21)"
								partition6="$(echo "${fsoptions}" | cut -d'^' -f22)*$(echo "${fsoptions}" | cut -d'^' -f23)*$(echo "${fsoptions}" | cut -d'^' -f24)*$(echo "${fsoptions}" | cut -d'^' -f25)*$(echo "${fsoptions}" | cut -d'^' -f26)*$(echo "${fsoptions}" | cut -d'^' -f27)"
								partition7="$(echo "${fsoptions}" | cut -d'^' -f28)*$(echo "${fsoptions}" | cut -d'^' -f29)*$(echo "${fsoptions}" | cut -d'^' -f30)*$(echo "${fsoptions}" | cut -d'^' -f31)*$(echo "${fsoptions}" | cut -d'^' -f32)*$(echo "${fsoptions}" | cut -d'^' -f33)"
								partition8="$(echo "${fsoptions}" | cut -d'^' -f34)*$(echo "${fsoptions}" | cut -d'^' -f35)*$(echo "${fsoptions}" | cut -d'^' -f36)*$(echo "${fsoptions}" | cut -d'^' -f37)*$(echo "${fsoptions}" | cut -d'^' -f38)*$(echo "${fsoptions}" | cut -d'^' -f39)"
							else
								swap_size=$(echo "${fsoptions}" | cut -d'^' -f1)
								boot_name="Boot"
								root_name="Root"
								root_fstype=$(if echo "${fsoptions}" | cut -d'^' -f2 | grep -q btrfs; then echo "btrfs"; else echo "ext4"; fi)
								root_size=$(( ${install_size} - 1 ))
								root_encryption=$(if echo "${fsoptions}" | cut -d'^' -f2 | grep -q encryption; then echo "Yes"; else echo "No"; fi)
								root_compression=$(if echo "${fsoptions}" | cut -d'^' -f2 | grep -q compression; then echo "Yes"; else echo "No"; fi)
							fi
							compute_partitions
							until false; do
								if [ "${root_encryption}" == "Yes" ]; then
									encrypted_text="Please enter your user account details and encryption password."
								else
									encrypted_text="Please enter your user account details."
								fi
								form=$(gui_launch -m user -t "User creation" -p "$(echo ${environment} | cut -d '/' -f1)"^$(if [ "${root_encryption}" == "Yes" ] || [ "$(get_extra_partitions_attribute isencryptionused)" == "Yes" ]; then echo "Yes"; else echo "No"; fi) -q "${encrypted_text}")
								useraccount_name="$(echo ${form} | cut -d'^' -f1)"
								useraccount_password="$(echo ${form} | cut -d'^' -f2)"
								useraccount_password_verification="$(echo ${form} | cut -d'^' -f3)"
								useraccount_autologin="$(echo ${form} | cut -d'^' -f4)"
								user_password_for_encryption="$(echo ${form} | cut -d'^' -f5)"
								encryption_password="$(echo ${form} | cut -d'^' -f6)"
								encryption_password_verification="$(echo ${form} | cut -d'^' -f7)"
								if [ -z "${form}" ]; then exit 1; fi
								if [ "${form}" == "return" ]; then break; continue; fi
								if [ -z "${useraccount_name}" ]; then gui_launch -m messagebox -t "Error during user creation" -q "Please define a user account name."; continue; fi
								if ! echo "${useraccount_name}" | grep -q '^[a-z][-a-z0-9]*$'; then gui_launch -m messagebox -t "Error during user creation" -q "Invalid Username (username can only contain lowercase and numerical characters)."; continue; fi
								if [ -z "${useraccount_password}" ]; then gui_launch -m messagebox -t "Error during user creation" -q "Please define a user account password."; continue; fi
								if ! echo "${useraccount_password}" | grep -q '[^^^]*$'; then gui_launch -m messagebox -t "Error during user creation" -q "User account password contains unsupported characters."; continue; fi
								if [ "${useraccount_password}" != "${useraccount_password_verification}" ]; then gui_launch -m messagebox -t "Error during user creation" -q "User account password and verification password do not match."; continue; fi
								if ([ "${root_encryption}" == "Yes" ] || [ "$(get_extra_partitions_attribute isencryptionused)" == "Yes" ]) && [ "${user_password_for_encryption}" == "No" ]; then
									if [ -z "${encryption_password}" ]; then gui_launch -m messagebox -t "Error during user creation" -q "Please define the encryption password."; continue; fi
									if echo "${encryption_password}" | grep -q '[^a-zA-Z0-9 ()[]{}!@#&$£%µ+-\*/=~¨²]'; then gui_launch -m messagebox -t "Error during user creation" -q "Encryption password contains unsupported characters."; continue; fi
									if [ "${encryption_password}" != "${encryption_password_verification}" ]; then gui_launch -m messagebox -t "Error during user creation" -q "Encryption password and verification password do not match."; continue; fi
								elif [ "${root_encryption}" == "Yes" ] || [ "$(get_extra_partitions_attribute isencryptionused)" == "Yes" ]; then
									encryption_password="${useraccount_password}"
								fi
								until false; do
									for i in "${!available_locales[@]}"; do if [ "${available_locales[$i]}" == "TRUE" ] || [ "${available_locales[$i]}" == "FALSE" ]; then if [ -z "${languages}" ]; then languages="${available_locales[$i+1]} (${available_locales[$i+2]})"; else languages="${languages};${available_locales[$i+1]} (${available_locales[$i+2]})"; fi; fi; done
									if [[ " ${available_locales[*]} " =~ " $(cat /etc/locale.conf | grep 'LANG=' | cut -d'=' -f2 | cut -d'.' -f1 2>/dev/null) " ]]; then current_language="$(cat /etc/locale.conf | grep 'LANG=' | cut -d'=' -f2 | cut -d'.' -f1 2>/dev/null)"; fi
									for i in "${!available_keymaps[@]}"; do if [ "${available_keymaps[$i]}" == "TRUE" ] || [ "${available_keymaps[$i]}" == "FALSE" ]; then if [ -z "${keymaps}" ]; then keymaps="${available_keymaps[$i+1]} (${available_keymaps[$i+2]})"; else keymaps="${keymaps};${available_keymaps[$i+1]} (${available_keymaps[$i+2]})"; fi; fi; done
									if [[ " ${available_keymaps[*]} " =~ " $(cat /etc/vconsole.conf | grep 'KEYMAP=' | cut -d'=' -f2 2>/dev/null) " ]]; then current_keymap="$(cat /etc/vconsole.conf | grep 'KEYMAP=' | cut -d'=' -f2 2>/dev/null)"; fi
									for i in "${!available_timezones[@]}"; do if [ "${available_timezones[$i]}" == "TRUE" ] || [ "${available_timezones[$i]}" == "FALSE" ]; then if [ -z "${timezones}" ]; then timezones="${available_timezones[$i+1]}"; else timezones="${timezones};${available_timezones[$i+1]}"; fi; fi; done
									if [[ " ${available_timezones[*]} " =~ " $(realpath --relative-to /usr/share/zoneinfo /etc/localtime 2>/dev/null) " ]]; then current_timezone="$(realpath --relative-to /usr/share/zoneinfo /etc/localtime 2>/dev/null)"; fi
									settings=$(gui_launch -m parameters -t "Language, Keyboard and Timezone selection" -p "${languages}^${current_language}^${keymaps}^${current_keymap}^${timezones}^${current_timezone}" -q "Please select your locale (language / formats), keyboard layout and timezone.")
									if [ -z "${settings}" ]; then exit 1; fi
									if [ "${settings}" == "return" ]; then break; continue; fi
									locale=$(echo "${settings}" | cut -d'^' -f1 | cut -d' ' -f1)
									keymap=$(echo "${settings}" | cut -d'^' -f2 | cut -d' ' -f1)
									timezone=$(echo "${settings}" | cut -d'^' -f3 | cut -d' ' -f1)
									until false; do
										if [ "${distribution}" != "Qubes" ]; then customizations_list="$(echo "${distribution}" | sed 's@[ !]@@g')-${RANDOM}^"; else customizations_list="^"; fi
										customizations_list="${customizations_list}hide_grub^"
										if [ "${nvidia_supported}" == "Yes" ]; then customizations_list="${customizations_list}nvidia^"; else customizations_list="${customizations_list}^"; fi
										if [ "${surface_supported}" == "Yes" ]; then customizations_list="${customizations_list}surface^"; else customizations_list="${customizations_list}^"; fi
										customizations_list="${customizations_list}custom_packages^$(pwd)^kernel_parameters^${mirrors_supported[@]}"
										customizations=$(gui_launch -m customizations -t "Custom settings selection" -p "${customizations_list}" -q "If needed, customize your installation with these additional settings.")
										if [ -z "${customizations}" ]; then exit 1; fi
										if [ "${distribution}" != "Qubes" ] && ! echo "${customizations}" | cut -d'^' -f1 | grep -Pq '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'; then gui_launch -m messagebox -t "Error in hostname selection" -q "hostname contains unsupported characters."; continue; fi
										if [ "${customizations}" == "return" ]; then break; continue; fi
										hostname=$(echo "${customizations}" | cut -d'^' -f1)
										grub_hide=$(echo "${customizations}" | cut -d'^' -f2)
										nvidia=$(echo "${customizations}" | cut -d'^' -f3)
										surface=$(echo "${customizations}" | cut -d'^' -f4)
										custom_packages=$(echo "${customizations}" | cut -d'^' -f5)
										custom_script=$(echo "${customizations}" | cut -d'^' -f6)
										kernel_parameters=$(echo "${customizations}" | cut -d'^' -f7)
										mirror=8; for i in $(echo "${customizations_list}" | cut -d'^' -f"${mirror}"); do
											if [ ! -z $(echo "${customizations}" | cut -d'^' -f"${mirror}") ]; then
												set_mirror "${i}" $(echo "${customizations}" | cut -d'^' -f"${mirror}") || { gui_launch -m messagebox -t "Error in mirror selection" -q "Selected ${i} mirror is invalid: $(echo ${customizations} | cut -d'^' -f${mirror})."; continue 2; }
											fi
											mirror=$(( $mirror + 1 ))
										done
										break 9
									done
								done
							done
						done
					else
						break 5
					fi
				done
			done
		done
	done
done
if [ ! -z "${generate_config}" ]; then generate_declarative_config; fi
if [ "${install_type}" == "disk" ]; then
	confirmation=$(gui_launch -m confirmation -t "Drive erasing confirmation" -q "WARNING: All data on device ${destination} will be erased, are you sure you want to continue ?")
	if [ -z "${confirmation}" ]; then exit 1; fi
	gui_launch -m progress -t "Installation in progress" -q "Installing ${distribution} ${version} with ${environment} environment on drive ${fullpath}.<br><br>You can follow the install process in the terminal window." -w "/tmp/linuxloops_gui.pid" &
	start_install
	kill $(cat /tmp/linuxloops_gui.pid) 2>/dev/null
	rm /tmp/linuxloops_gui.pid
	if [ ${return_value} -eq 1 ]; then exit_with_error "Failed to perform the installation of ${distribution} ${version} in chroot."; fi
	gui_launch -m finished -t "Installation finished" -q "Linuxloops installation process is finished.<br><br>You can now reboot your computer and start ${distribution} by selecting your device in the UEFI boot menu."
else
	gui_launch -m progress -t "Installation in progress" -q "Installing ${distribution} ${version} with ${environment} environment in the disk image ${fullpath}.<br><br>You can follow the install process in the terminal window." -w "/tmp/linuxloops_gui.pid" &
	start_install
	kill $(cat /tmp/linuxloops_gui.pid) 2>/dev/null
	rm /tmp/linuxloops_gui.pid
	if [ ${return_value} -eq 1 ]; then exit_with_error "Failed to perform the installation of ${distribution} in chroot."; fi
	grub_config
	if [ ! -z "${wsl}" ]; then
		grubinstall="The ${distribution} disk image has been created at $(echo ${fullpath:5:1} | tr a-z A-Z):\\$(echo ${fullpath:7} | sed 's@\/@\\@g'). You can either write this disk image to a usb flashdrive / sdcard with a tool like DiskImager or boot it directly using Grub2Win.<br><br>********************************************************************************************<br>If you want to boot the image directly using Grub2Win:<br>The grub config needed to boot ${distribution} has been generated in the file $(echo ${fullpath:5:1} | tr a-z A-Z):\\$(echo ${fullpath:7} | sed 's@\/@\\@g').grub.txt<br>You need to install Grub2Win and launch it, click on \"Manage Boot Menu\" -> \"Add a new entry\" -> set \"Type\" as \"Create user section\", open the file $(echo ${fullpath:5:1} | tr a-z A-Z):\\$(echo ${fullpath:7} | sed 's@\/@\\@g').grub.txt and copy its content in the Grub2Win notepad window, save and close the Grub2Win notepad window then click \"Apply\" and \"OK\".<br><br>Please note that ${distribution} will not be bootable and / or stable if you do not perform the below actions (Refer to Windows online resources if needed):<br>- Ensure that bitlocker is disabled on the drive which contains the ${distribution} image or disable it.<br>- Disable fast startup.<br>- Disable hibernation.<br><br>Once done, reboot your computer and select ${distribution} from the Grub2Win menu.<br>********************************************************************************************"
		gui_launch -m finished -t "Grub configuration" -q "${grubinstall}"
	elif [ ! -z "${brunch}" ]; then
		grubinstall="The grub config needed to boot ${distribution} has been generated in the file \"${fullpath}.grub.txt\".<br><textarea cols=\"80\" rows=\"14\" style=\"font-size: 14px;\">${config}</textarea><br><br>Now copy the above grub config, run \"sudo edit-brunch-config -g\" and paste it (lines between stars) at the end of the file.<br><br>Once done, press CTRL+X and then ENTER to save, reboot your computer and start ${distribution}"
		gui_launch -m finished -t "Grub configuration" -q "${grubinstall}"
	elif [ ! -z "${chromeos}" ]; then
		grubinstall="The grub config needed to boot ${distribution} has been added to the ChromeOS EFI partition (12). If not already done, enable booting from ALT firmware, then reboot your computer and press CTRL+L to start ${distribution}."
		gui_launch -m finished -t "Grub configuration" -q "${grubinstall}"
	else
		if [ -d /boot/grub2 ]; then grub="grub2"; else grub="grub"; fi
		grubinstall="The grub config needed to boot ${distribution} has been generated in the file \"${fullpath}.grub.txt\".<br><br>If you have a linux distribution installed which uses grub as bootloader, run the below command to generate the grub config automatically:<br><textarea id=\"configuration\" cols=\"80\" rows=\"4\" style=\"font-size: 14px;\">sudo cat /etc/grub.d/40_custom ${fullpath}.grub.txt | sudo tee /etc/grub.d/99_linuxloops_$(echo ${distribution} | tr [:upper:] [:lower:]); sudo chmod 0755 /etc/grub.d/99_linuxloops_$(echo ${distribution} | tr [:upper:] [:lower:]); sudo ${grub}-mkconfig -o $(if cat /etc/os-release | grep 'VARIANT_ID=' | grep -q 'silverblue\|kinoite'; then echo /etc/grub2.cfg; else echo /boot/${grub}/grub.cfg; fi)</textarea><br><button onclick=\"copy_configuration()\">Copy command to clipboard</button><br><br>Otherwise, add the grub config manually to another grub bootloader.<br><br>You can then reboot your computer and start ${distribution}."
		gui_launch -m finished -t "Grub configuration" -q "${grubinstall}"
	fi
fi
}

cli_installer()
{
if [ "${declarative}" == "Yes" ]; then
	if [ ! -f "$(realpath ${declarative_config})" ]; then echo "Declarative file not found at path: $(realpath ${declarative_config})."; exit 1; fi
	source "$(realpath ${declarative_config})"
	if [ ! -z "${custom_packages}" ]; then custom_packages=$(echo ${custom_packages} | sed -e 's@\n@ @g'); fi
	if [ ! -z "${custom_commands}" ]; then
		cat >"${linuxloopsdir}"/custom_commands <<CUSTOM_COMMANDS
#!/bin/bash
set -e
# Add temporarily setuid bit to bubblewrap to be able to install flatpaks (as namespaces cannot be created in chroot)
if [ -x /usr/bin/bwrap ] && [ ! -u /usr/bin/bwrap ]; then bwrap_needs_setuid=1; chmod u+s /usr/bin/bwrap; fi
${custom_commands}
if [ ! -z "\${bwrap_needs_setuid}" ]; then chmod u-s /usr/bin/bwrap; fi
CUSTOM_COMMANDS
		chmod 0755 "${linuxloopsdir}"/custom_commands
		custom_script="${linuxloopsdir}"/custom_commands
	fi
fi
if [ -z "${distribution}" ] || [[ ! " ${available_distributions[*]} " =~ " ${distribution} " ]]; then echo -e "Please select a distribution from the below list:"; list_array "available_distributions"; exit 1; fi
check_home_space
if [ $(( ($(df -k --output=avail "${linuxloopsdir}" | sed 1d) / 1024 / 1024) - ${available_space_needed} )) -lt 0 ]; then
	echo -e "To install ${distribution} you need ${available_space_needed} GB of available space in your home directory but you only have $(($(df -k --output=avail ${HOME} | sed 1d) / 1024 / 1024)) GB."
	exit 1
fi
distribution_parameters
if [ ! -z "${version}" ] && [[ ! " ${available_versions[*]} " =~ " ${version} " ]]; then echo -e "Please select a version from the below list:"; list_array "available_versions"; exit 1; elif [ -z "${version}" ]; then version="${default_version}"; fi
distribution_version_parameters
if [ -z "${environment}" ] || [[ ! " ${available_environments[*]} " =~ " ${environment} " ]]; then echo -e "Please select an environment from the below list:"; list_array "available_environments"; exit 1; fi
if [ -z "${hostname}" ]; then hostname="$(echo "${distribution}" | sed 's@[ !]@@g')-${RANDOM}"; fi
if [ -z "${locale}" ]; then locale="en_US"; fi
if [ -z "${keymap}" ]; then keymap="us"; fi
if [ -z "${timezone}" ]; then timezone="UTC"; fi
if [ -z "${destination}" ]; then
	until false; do
		read -p "Please input the destination drive (eg. /dev/sdX) or the destination image path: " destination
		if ! echo "${destination}" | grep -Eq '/[a-zA-Z0-9_/-]*$'; then echo -e "Destination path contains unsupported characters.\n\n"; continue; fi
		if [ -z "${destination##/dev/*}" ]; then install_type="disk"; else install_type="image"; fi
		if [ "${install_type}" == "disk" ]; then
			if [ ! -b "${destination}" ]; then echo -e "Disk ${destination} was not found.\n\n"; continue; fi
			if [ ! "$(lsblk ${destination} -nd -o TYPE)" == "disk" ]; then echo -e "Linuxloops can only be installed on a full disk.\n\n"; continue; fi
			if [ $(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024 / 1024) )) -lt 14 ]; then echo -e "Linuxloops does not support disks with less than 14 GB available.\n\n"; continue; fi
			fullpath="${destination}"
			until false; do
				read -p "Please select the disk install size in GB (minimum 14 GB, maximum $(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024 / 1024) )) GB, default $(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024 / 1024) )) GB): " install_size
				if [ -z "${install_size}" ]; then
					install_size=$(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024 / 1024) ))
				elif [ -z "${install_size##*[!0-9]*}" ] || [ "${install_size}" -lt 0 ]; then
					echo -e "Disk install size is not a positive integer: ${install_size}.\n\n"
					continue
				elif [ "${install_size}" -lt 14 ]; then
					echo -e "Disk install size cannot be lower than 14 GB.\n\n"
					continue
				elif [ "${install_size}" -gt $(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024 / 1024) )) ]; then
					echo -e "Disk install size cannot be greater than $(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024 / 1024) )) GB.\n\n"
					continue
				fi
				if [ "${install_size}" -eq $(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024 / 1024) )) ]; then install_sizeMB=$(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 /1024) )); else install_sizeMB=$((install_size*1024)); fi
				break 2
			done
		else
			if [[ "${destination}" == *"/"* ]] && ([ -z "$(realpath ${destination} 2> /dev/null)" ] || [ ! -d "$(echo $(realpath ${destination}) | sed 's![^/]*$!!')" ]); then echo -e "Desination path does not exist, please provide an existing path.\n\n"; continue; fi
			if [ "$(lsblk $(df -h --output=source $(echo $(realpath ${destination}) | sed 's![^/]*$!!') | tail -1) -no TYPE)" == "crypt" ]; then echo -e "Linuxloops disk images cannot be booted from an encrypted partition.\n\n"; continue; fi
			if [[ ! "${destination}" == *"/"* ]]; then path="${PWD}/"; else path="$(echo $(realpath ${destination}) | sed 's![^/]*$!!')"; fi
			fullpath="${path}$(basename ${destination})"
			if [ ! -z "${wsl}" ] && [ ! -z "${path##/mnt/*}" ]; then echo -e "The ${distribution} disk image has to be installed outside of the WSL VM, please specify a path such as /mnt/<drive letter>/...\n\n"; continue; fi
			if [ ! -z "${chromeos}" ] || [ ! -z "${brunch}" ] && [ ! -z "${path##/mnt/stateful_partition/unencrypted/*}" ]; then echo -e "The ${distribution} disk image has to be installed in the unencrypted data partition, please specify a path such as /mnt/stateful_partition/unencrypted/...\n\n"; continue; fi
			possible_image_size
			if [ ${maximum_image_size} -lt 14 ]; then echo -e "Linuxloops needs at least 14 GB available on the target partition.\n\n"; continue; fi
			until false; do
				read -p "Please select the disk image size in GB (minimum 14 GB, maximum ${maximum_image_size} GB, default 14 GB): " install_size
				if [ -z "${install_size}" ]; then
					install_size=14
				elif [ -z "${install_size##*[!0-9]*}" ] || [ "${install_size}" -lt 0 ]; then
					echo -e "Disk image size is not a positive integer: ${install_size}.\n\n"
					continue
				elif [ "${install_size}" -lt 14 ]; then
					echo -e "Disk image size cannot be lower than 14 GB.\n\n"
					continue
				elif [ "${install_size}" -gt $(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024 / 1024) )) ]; then
					echo -e "Disk image size cannot be greater than ${maximum_image_size} GB.\n\n"
					continue
				fi
				install_sizeMB=$(( install_size * 1024))
				break 2
			done
		fi
	done
else
	if [ -z "${destination##/dev/*}" ]; then install_type="disk"; else install_type="image"; fi
	if [ -z "${install_size}" ]; then
		if [ "${install_type}" == "image" ] && [ "${live}" == "Yes" ]; then
			install_size=7
		elif [ "${install_type}" == "image" ]; then
			install_size=14
		fi
	else
		if [ -z "${install_size##*[!0-9]*}" ] || [ "${install_size}" -lt 0 ]; then
			echo "Install size is not a positive integer: ${install_size}."
			exit 1
		elif [ "${install_size}" -lt 14 ]; then
			echo "Install size cannot be lower than 14 GB."
			exit 1
		fi
	fi
	if [ "${install_type}" == "disk" ]; then
		if [ ! -b "${destination}" ]; then echo "Disk ${destination} was not found."; exit 1; fi
		if [ ! "$(lsblk ${destination} -nd -o TYPE)" == "disk" ]; then echo "Linuxloops can only be installed on a full disk."; exit 1; fi
		fullpath="${destination}"
		if [ ! -z "${install_size}" ]; then if [ $(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024 / 1024) )) -lt "${install_size}" ]; then echo "You have requested an install size of ${install_size} GB but this device only has $(( ($(lsblk -drnbpf -o SIZE ${destination}) / 1024 / 1024 / 1024) )) GB available."; exit 1; fi; fi
		if [ -z "${install_size}" ]; then install_sizeMB=$(( ($(lsblk -drnbpf -o SIZE "${destination}") / 1024 / 1024) )); else install_sizeMB=$(( install_size * 1024 )); fi
	else
		if [[ "${destination}" == *"/"* ]] && ([ -z "$(realpath ${destination} 2> /dev/null)" ] || [ ! -d "$(echo $(realpath ${destination}) | sed 's![^/]*$!!')" ]); then echo "Desination path does not exist, please provide an existing path."; exit 1; fi
		if [ "$(lsblk $(df -h --output=source $(echo $(realpath ${destination}) | sed 's![^/]*$!!') | tail -1) -no TYPE)" == "crypt" ]; then echo "Linuxloops disk images cannot be booted from an encrypted partition."; exit 1; fi
		if [[ ! "${destination}" == *"/"* ]]; then path="${PWD}/"; else path="$(echo $(realpath ${destination}) | sed 's![^/]*$!!')"; fi
		fullpath="${path}$(basename ${destination})"
		if [ ! -z "${wsl}" ] && [ ! -z "${path##/mnt/*}" ]; then echo "The ${distribution} disk image has to be installed outside of the WSL VM, please specify a path such as /mnt/<drive letter>/..."; exit 1; fi
		if [ ! -z "${chromeos}" ] || [ ! -z "${brunch}" ] && [ ! -z "${path##/mnt/stateful_partition/unencrypted/*}" ]; then echo "The ${distribution} disk image has to be installed in the unencrypted data partition, please specify a path such as /mnt/stateful_partition/unencrypted/..."; exit 1; fi
		possible_image_size
		if [ $(( ${maximum_image_size} - ${install_size} )) -lt 0 ]; then echo -e "Maximum available space to create the ${distribution} image on this partition is ${maximum_image_size} GB.\nAvailable space: $(( ($(df -k --output=avail $(echo $(realpath ${destination}) | sed 's![^/]*$!!') | sed 1d) / 1024 / 1024) + ${freed_space} )) GB\nSpace needed to bootstrap: ${bootstrap_space} GB\nIf you think that available space value is incorrect, verify that you have correctly mounted the destination partition or if the partition is in ext4 format that there is no reserved space (cf. https://odzangba.wordpress.com/2010/02/20/how-to-free-reserved-space-on-ext4-partitions)"; exit 1; else install_sizeMB=$(( install_size * 1024)); fi
	fi
fi
if [ ! -z "${swap_size}" ]; then
	if [ -z "${swap_size##*[!0-9]*}" ] || [ "${swap_size}" -lt 0 ]; then echo "Provided swap size is not a positive integer: ${swap_size}."; exit 1; fi
	if [ "${swap_size}" -gt 0 ] && [ $(( install_sizeMB - (swap_size * 1024) )) -lt $(( 12 * 1024 )) ]; then echo "At least 12 GB should be available for the root partition, please increase the installation size or reduce the swap size."; exit 1; fi
fi
if [ "${distribution}" == "BlissOS" ] || [ "${distribution}" == "Brunch" ] || [ "${distribution}" == "ChromeOS-Flex" ] || [ "${distribution}" == "Tails" ]; then
	if [ "${root_encryption}" == "Yes" ]; then echo -e "rootfs encryption is not supported with ${distribution}.\n"; exit 1; fi
	if [ ! -z "${swap_size}" ] && [ "${swap_size}" -ne 0 ]; then echo -e "Swap cannot be enabled by design with ${distribution}.\n"; exit 1; fi
fi
compute_partitions
if [ ! $(list_array "available_locales" | grep -w "${locale}") ]; then echo "Locale ${locale} is not available, supported locales are:"; echo $(list_array "available_locales" | sed -e 's@\n@ @g'); exit 1; fi
if [ ! $(list_array "available_keymaps" | grep -w "${keymap}") ]; then echo "Keymap ${keymap} is not available, supported keympas are:"; echo $(list_array "available_keymaps" | sed -e 's@\n@ @g'); exit 1; fi
if [ ! $(list_array "available_timezones" | grep -w "${timezone}") ]; then echo "Timezone ${timezone} is not available, supported timezones are:"; echo $(list_array "available_timezones" | sed -e 's@\n@ @g'); exit 1; fi
if [ -z "${chromeos}" ] && [ -z "${brunch}" ] && [ ! -z "${hostname}" ] && ! echo "${hostname}" | grep -Pq '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'; then echo "Provided hostname contains invalid characters."; exit 1; fi
if [ "${root_fstype}" == "btrfs" ] && [ ! "${btrfs_supported}" == "Yes" ]; then echo "Filesystem type btrfs is not available for this distribution version."; exit 1; fi
if [ "${nvidia}" == "Yes" ] && [ ! "${nvidia_supported}" == "Yes" ]; then echo "nvidia proprietary driver is not available for this distribution version."; exit 1; fi
if [ "${surface}" == "Yes" ] && [ ! "${surface_supported}" == "Yes" ]; then echo "Surface patches are not available for this distribution version."; exit 1; fi
if [ "${live}" == "Yes" ] && ([ ! "${distribution}" == "Debian" ] && [ ! "${distribution}" == "Linuxmint" ]); then echo "Linuxloops live can only be created with Debian or Linuxmint distributions."; exit 1; fi
if [ ! -z "${custom_script}" ] && [ ! -f "${custom_script}" ]; then echo "Custom script ${1} could not be found."; exit 1; fi
if [ "${distribution}" != "BlissOS" ] && [ "${distribution}" != "Brunch" ] && [ "${distribution}" != "ChromeOS-Flex" ] && [ "${distribution}" != "Tails" ]; then
	if [ "${test_distribution}" == "Yes" ]; then
		useraccount_name="test"
		useraccount_password="test"
		encryption_password="test"
	elif [ "${live}" == "Yes" ]; then
		useraccount_name="live"
		useraccount_password="linuxloops"
		encryption_password="linuxloops"
	else
		if [ ! -z "${useraccount_name}" ]; then
			if ! echo "${useraccount_name}" | grep -q '^[a-z][-a-z0-9]*$'; then echo -e "Invalid user account name (username can only contain lowercase and numerical characters).\n\n"; exit 1; fi	
		else
			until false; do
				read -p "Please enter your user account name: " useraccount_name
				if [ -z "${useraccount_name}" ]; then echo -e "Please define a user account name.\n\n"; continue; fi
				if ! echo "${useraccount_name}" | grep -q '^[a-z][-a-z0-9]*$'; then echo -e "Invalid user account name (username can only contain lowercase and numerical characters)\n\n"; continue; fi
				break
			done
		fi
		if [ ! -z "${useraccount_password}" ]; then
			if ! echo "${useraccount_password}" | grep -q '[^^^]*$'; then echo -e "Invalid character in user account password (passwords cannot contain the ^ character).\n\n"; exit 1; fi
		else
			until false; do
				read -s -p "Input your user account password: " useraccount_password
				echo ""
				read -s -p "Verify your user account password: " useraccount_password_verification
				echo ""
				if [ -z "${useraccount_password}" ]; then echo -e "Please define a user account password.\n\n"; continue; fi
				if ! echo "${useraccount_password}" | grep -q '[^^^]*$'; then echo -e "Invalid character in password (passwords cannot contain the ^ character).\n\n"; continue; fi
				if [ "${useraccount_password}" != "${useraccount_password_verification}" ]; then echo -e "User account password and verification password do not match.\n\n"; continue; fi
				break
			done
		fi
		if ([ "${root_encryption}" == "Yes" ] || [ "$(get_extra_partitions_attribute isencryptionused)" == "Yes" ]) && ([ -z "${user_password_for_encryption}" ] || [ "${user_password_for_encryption}" == "No" ]); then
			if [ ! -z "${encryption_password}" ]; then
				if ! echo "${encryption_password}" | grep -q '[^^^]*$'; then echo -e "Invalid character in encryption password (passwords cannot contain the ^ character).\n\n"; exit 1; fi
			else
				until false; do
					read -s -p "Input your encryption password: " encryption_password
					echo ""
					read -s -p "Verify your encryption password: " encryption_password_verification
					echo ""
					if [ -z "${encryption_password}" ]; then echo -e "Please define the encryption password.\n\n"; continue; fi
					if echo "${encryption_password}" | grep -q '[^a-zA-Z0-9 ()[]{}!@#&$£%µ+-\*/=~¨²]'; then echo -e "Encryption password contains unsupported characters.\n\n"; continue; fi
					if [ "${encryption_password}" != "${encryption_password_verification}" ]; then echo -e "Encryption password and verification password do not match.\n\n"; continue; fi
					break
				done
			fi
		elif [ "${root_encryption}" == "Yes" ] || [ "$(get_extra_partitions_attribute isencryptionused)" == "Yes" ]; then
			encryption_password="${useraccount_password}"
		fi
	fi
fi
if [ ! -z "${generate_config}" ]; then generate_declarative_config; fi
if [ "${install_type}" == "disk" ]; then
	read -p "WARNING: All data on device ${destination} will be erased, are you sure you want to continue ? (type yes to continue)"$'\n' confirm
	if [ -z ${confirm} ] || [ ! ${confirm} == "yes" ]; then echo "Invalid answer ${confirm}, exiting"; exit 1; fi
	start_install || exit_with_error "Failed to install ${distribution} in chroot."
	echo -e "\nLinuxloops installation process is finished.\nYou can now reboot your computer and start ${distribution} by selecting your device in the UEFI boot menu."
else
	start_install || exit_with_error "Failed to install ${distribution} in chroot."
	grub_config
	if [ ! -z "${wsl}" ]; then
		grubinstall="The ${distribution} disk image has been created at $(echo ${fullpath:5:1} | tr a-z A-Z):\\\\$(echo ${fullpath:7} | sed 's@\/@\\\\@g'). You can either write this disk image to a usb flashdrive / sdcard with a tool like DiskImager or boot it directly using Grub2Win.\n\n********************************************************************************************\nIf you want to boot the image directly using Grub2Win:\nThe grub config needed to boot ${distribution} has been generated in the file $(echo ${fullpath:5:1} | tr a-z A-Z):\\\\$(echo ${fullpath:7} | sed 's@\/@\\\\@g').grub.txt\nYou need to install Grub2Win and launch it, click on \"Manage Boot Menu\" -> \"Add a new entry\" -> set \"Type\" as \"Create user section\", open the file $(echo ${fullpath:5:1} | tr a-z A-Z):\\\\$(echo ${fullpath:7} | sed 's@\/@\\\\@g').grub.txt and copy its content in the Grub2Win notepad window, save and close the Grub2Win notepad window then click \"Apply\" and \"OK\".\nPlease note that ${distribution} will not be bootable and / or stable if you do not perform the below actions (Refer to Windows online resources if needed):\n- Ensure that bitlocker is disabled on the drive which contains the ${distribution} image or disable it.\n- Disable fast startup.\n- Disable hibernation.\n\nOnce done, reboot your computer and select ${distribution} from the Grub2Win menu.\n********************************************************************************************"
		echo -e "\n${grubinstall}"
	elif [ ! -z "${brunch}" ]; then
		grubinstall="The grub config needed to boot ${distribution} has been generated in the file \"${fullpath}.grub.txt\".\n\n****************************************************************************************** \n${config}\n****************************************************************************************** \n\nNow copy the above grub config, run \"sudo edit-brunch-config -g\" and paste it (lines between stars) at the end of the file.\n\nOnce done, press CTRL+X and then ENTER to save, reboot your computer and start ${distribution}"
		echo -e "\n${grubinstall}"
	elif [ ! -z "${chromeos}" ]; then
		grubinstall="The grub config needed to boot ${distribution} has been added to the ChromeOS EFI partition (12). If not already done, enable booting from ALT firmware, then reboot your computer and press CTRL+L to start ${distribution}."
		echo -e "\n${grubinstall}"
	else
		if [ -d /boot/grub2 ]; then grub="grub2"; else grub="grub"; fi
		grubinstall="The grub config needed to boot ${distribution} has been generated in the file \"${fullpath}.grub.txt\".\n\nIf you have a linux distribution installed which uses grub as bootloader, run the below command to generate the grub config automatically:\n********************************************************************************************\nsudo cat /etc/grub.d/40_custom ${fullpath}.grub.txt | sudo tee /etc/grub.d/99_linuxloops_$(echo ${distribution} | tr [:upper:] [:lower:]); sudo chmod 0755 /etc/grub.d/99_linuxloops_$(echo ${distribution} | tr [:upper:] [:lower:]); sudo ${grub}-mkconfig -o $(if cat /etc/os-release | grep 'VARIANT_ID=' | grep -q 'silverblue\|kinoite'; then echo /etc/grub2.cfg; else echo /boot/${grub}/grub.cfg; fi)\n********************************************************************************************\n\nOtherwise, add the below grub config manually to another grub bootloader:\n********************************************************************************************\n${config}*******************************************************************************************\n\nYou can then reboot your computer and start ${distribution}."
		echo -e "\n${grubinstall}"
	fi
fi
rm -f "${linuxloopsdir}"/custom_commands
}

check_dependencies()
{
if ( ! test -z {,} ); then echo "Linuxloops must be ran with \"bash\"."; exit 1; fi
if [ -z "$(command -v basename)" ]; then echo "\"basename\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v base64)" ]; then echo "\"base64\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v blkid)" ]; then echo "\"blkid\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v cat)" ]; then echo "\"cat\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v chmod)" ]; then echo "\"chmod\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v chown)" ]; then echo "\"chown\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v chroot)" ]; then echo "\"chroot\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v cp)" ]; then echo "\"cp\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v curl)" ]; then echo "\"curl\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v cut)" ]; then echo "\"cut\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v dd)" ]; then echo "\"dd\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v df)" ]; then echo "\"df\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v dirname)" ]; then echo "\"dirname\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v du)" ]; then echo "\"du\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v expr)" ]; then echo "\"expr\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v echo)" ]; then echo "\"echo\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v find)" ]; then echo "\"find\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v grep)" ]; then echo "\"grep\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v kill)" ]; then echo "\"kill\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v losetup)" ]; then echo "\"losetup\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v lsblk)" ]; then echo "\"lsblk\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v mkdir)" ]; then echo "\"mkdir\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v mktemp)" ]; then echo "\"mktemp\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v mount)" ]; then echo "\"mount\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v mountpoint)" ]; then echo "\"mountpoint\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v realpath)" ]; then echo "\"realpath\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v rm)" ]; then echo "\"rm\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v sed)" ]; then echo "\"sed\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v sha256sum)" ]; then echo "\"sha256sum\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v tar)" ]; then echo "\"tar\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v touch)" ]; then echo "\"touch\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v tr)" ]; then echo "\"tr\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v umount)" ]; then echo "\"umount\" binary needs to be installed first."; exit 1; fi
if [ -z "$(command -v xz)" ]; then echo "\"xz\" binary needs to be installed first."; exit 1; fi
if [ $(whoami) != "root" ]; then echo "Please run with this script with sudo."; exit 1; fi
}

set_base_parameters()
{
if [ -z ${SUDO_UID} ]; then
	SUDO_USER=${USER}
	SUDO_UID=$(id -g ${USER})
fi
linuxloopsdir="$(eval echo ~${SUDO_USER})"/.cache/linuxloops
mkdir -p "${linuxloopsdir}"/tmp
chown ${SUDO_USER}:$(id -g ${SUDO_UID}) "${linuxloopsdir}" "${linuxloopsdir}/tmp"
chmod 0755 "${linuxloopsdir}" "${linuxloopsdir}/tmp"
if grep -qi 'Microsoft' /proc/version; then wsl=1; fi
if [ -d /home/runner/work ]; then github=1; fi
if [ "$(grep -o 'NAME=[^,]\+' /etc/os-release | cut -d'=' -f2)" == "Chrome OS" ]; then if [ -f /etc/brunch_version ]; then brunch=1; else chromeos=1; fi; fi
}

set +H
if [[ $EUID -ne 0 ]]; then
	if [ -f /etc/NIXOS ] && [ ${#} -eq 0 ]; then
        	exec sudo nix-shell -p bash curl gnupg1 sudo util-linux xz gtk3 glib-networking python3Packages.pygobject3 webkitgtk_4_1 --run "GIO_MODULE_DIR=\$(nix-instantiate --eval-only --raw --expr '(import <nixos> {}).glib-networking.outPath')/lib/gio/modules XDG_DATA_DIRS=\$XDG_DATA_DIRS:\$GSETTINGS_SCHEMAS_PATH:\$XDG_ICON_DIRS bash $0"
	else
		exec sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR bash "$0" "$@"
	fi
fi
if [ -f /etc/NIXOS ]; then
	unset GDK_PIXBUF_MODULE_FILE PYTHONPATH TEMP TEMPDIR TMP TMPDIR
	export XDG_DATA_DIRS=${XDG_DATA_DIRS}:/usr/share
fi
set_base_parameters
if [ ${#} -eq 0 ] || ([ ${#} -eq 2 ] && [ "${1}" == "-G" ]) || ([ ${#} -eq 2 ] && [ "${1}" == "--generate-config" ]); then
	if ([ ${#} -eq 2 ] && [ "${1}" == "-G" ]) || ([ ${#} -eq 2 ] && [ "${1}" == "--generate-config" ]); then
		if [ -z "${2}" ]; then echo -e "Please provide a path for the generated config."; exit 1; fi
		if ! echo "${2}" | grep -Eq '/[a-zA-Z0-9_/-]*$'; then echo -e "The path for the generated config contains unsupported characters."; exit 1; fi
		if [[ "${2}" == *"/"* ]] && ([ -z "$(realpath ${2} 2> /dev/null)" ] || [ ! -d "$(echo $(realpath ${2}) | sed 's![^/]*$!!')" ]); then echo "The path for the generated config does not exist, please provide an existing path."; exit 1; fi
		generate_config="${2}"
	fi
	if [ -z "$(command -v python3)" ]; then echo "To use the GUI installer you need to install the \"python3\" package."; exit 1; fi
	if [ -z "$(python3 -V 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1)$(python3 -V 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f2)" ] || [ $(python3 -V 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1)$(python3 -V 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f2) -lt 310 ]; then echo "Please install python version 3.10 or above."; exit 1; fi
	if ! python3 -c "import venv" 2>/dev/null; then echo "Please install python3-venv package."; exit 1; fi
	gui=1
	check_dependencies
	if ! curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/sebanc/linuxloops > /dev/null 2>&1; then echo -e "Internet connection not available, please make sure you are connected to the internet."; exit 1; fi
	gui_installer
else
	while [ ${#} -gt 0 ]; do
		case "${1}" in
			-distro | --distribution)
				shift
				distribution="${1}"
			;;
			-ver | --version)
				shift
				version="${1}"
			;;
			-env | --environment)
				shift
				environment="${1}"
			;;
			-dst | --destination)
				shift
				destination="${1}"
			;;
			-s | --size)
				shift
				install_size="${1}"
			;;
			-z | --swapsize)
				shift
				swap_size="${1}"
			;;
			-B | bin-path)
				shift
				bin_path="${1}"
			;;
			-a | --autologin)
				useraccount_autologin="Yes"
			;;
			--efi-name)
				shift
				efi_name="${1}"
			;;
			--efi-mountoptions)
				shift
				efi_mountoptions="${1}"
			;;
			--boot-name)
				shift
				boot_name="${1}"
			;;
			--boot-mountoptions)
				shift
				boot_mountoptions="${1}"
			;;
			--root-name)
				shift
				root_name="${1}"
			;;
			--root-mountoptions)
				shift
				root_mountoptions="${1}"
			;;
			-A | --add-partition)
				shift
				if [ -z "${partition4}" ]; then
					partition4="${1}"
				elif [ -z "${partition5}" ]; then
					partition5="${1}"
				elif [ -z "${partition6}" ]; then
					partition6="${1}"
				elif [ -z "${partition7}" ]; then
					partition7="${1}"
				elif [ -z "${partition8}" ]; then
					partition8="${1}"
				else
					echo "Linuxloops supports a maximum of 8 partitions."
					exit 1
				fi
			;;
			-b | --btrfs)
				root_fstype="btrfs"
			;;
			-r | --rootfs-compression)
				root_fstype="btrfs"
				root_compression="Yes"
			;;
			-e | --encrypt)
				root_encryption="Yes"
			;;
			-H | --hostname)
				shift
				hostname="${1}"
			;;
			-L | --locale)
				shift
				locale="${1}"
			;;
			-K | --keymap)
				shift
				keymap="${1}"
			;;
			-T | --timezone)
				shift
				timezone="${1}"
			;;
			-n | --nvidia)
				nvidia="Yes"
			;;
			-S | --surface)
				surface="Yes"
			;;
			-c | --custom-packages)
				shift
				custom_packages="${1}"
			;;
			-C | --custom-script)
				shift
				custom_script="$(sudo -u ${SUDO_USER} echo $(realpath ${1}))"
			;;
			-k | --kernel-parameters)
				shift
				kernel_parameters="${1}"
			;;
			-m | --custom-mirror)
				shift
				if [ -z "${distribution}" ]; then echo "Distribution and version parameters need to be provided."; exit 1; fi
				if [[ ! " ${available_distributions[*]} " =~ " ${distribution} " ]]; then echo -e "Please select a distribution from the below list:"; list_array "available_distributions"; exit 1; fi
				distribution_parameters
				if [[ ! " ${available_versions[*]} " =~ " ${version} " ]]; then echo -e "Please select a version from the below list:"; list_array "available_versions"; exit 1; fi
				distribution_version_parameters
				if [ "${1}" == "$(echo ${1} | cut -d'*' -f2)" ]; then echo "Please specify the repository name and the mirror separated with \"*\" such as \"Arch*https://mirrors.kernel.org/archlinux\"."; exit 1; fi
				if ! echo "$(echo ${1} | cut -d'*' -f2)" | grep -Eq '^(http|https)://[a-zA-Z0-9./?=_%:-]*'; then echo "Mirror should start by \"http://\" or \"https://\"."; exit 1; fi
				set_mirror "$(echo ${1} | cut -d'*' -f1)" "$(echo ${1} | cut -d'*' -f2)" || { echo "${1} mirror is either invalid or offline."; exit 1; }
			;;
			-p | --user-password-for-encryption)
				user_password_for_encryption="Yes"
			;;
			-g | --grub-hide)
				grub_hide="Yes"
			;;
			-G | --generate-declarative-config)
				shift
				if [ -z "${1}" ]; then echo -e "Please provide a path for the generated config."; exit 1; fi
				if ! echo "${1}" | grep -Eq '/[a-zA-Z0-9_/-]*$'; then echo -e "The path for the generated config contains unsupported characters."; exit 1; fi
				if [[ "${1}" == *"/"* ]] && ([ -z "$(realpath ${1} 2> /dev/null)" ] || [ ! -d "$(echo $(realpath ${1}) | sed 's![^/]*$!!')" ]); then echo "The path for the generated config does not exist, please provide an existing path."; exit 1; fi
				generate_config="${1}"
			;;
			-d | --apply-declarative-config)
				shift
				declarative="Yes"
				declarative_config="${1}"
			;;
			-l | --list)
				list_array "all"
				exit 0
			;;
			-lb | --list-btrfs)
				if [ -z "${distribution}" ]; then echo "Distribution and version parameters need to be provided."; exit 1; fi
				if [[ ! " ${available_distributions[*]} " =~ " ${distribution} " ]]; then echo -e "Please select a distribution from the below list:"; list_array "available_distributions"; exit 1; fi
				distribution_parameters
				if [[ ! " ${available_versions[*]} " =~ " ${version} " ]]; then echo -e "Please select a version from the below list:"; list_array "available_versions"; exit 1; fi
				distribution_version_parameters
				echo -e ${btrfs_supported}
				exit 0
			;;
			-ld | --list-distributions)
				echo -e $(list_array "available_distributions" | sed -e 's@\n@ @g')
				exit 0
			;;
			-le | --list-environments)
				if [ -z "${distribution}" ]; then echo "Distribution and version parameters need to be provided."; exit 1; fi
				if [[ ! " ${available_distributions[*]} " =~ " ${distribution} " ]]; then echo -e "Please select a distribution from the below list:"; list_array "available_distributions"; exit 1; fi
				distribution_parameters
				if [[ ! " ${available_versions[*]} " =~ " ${version} " ]]; then echo -e "Please select a version from the below list:"; list_array "available_versions"; exit 1; fi
				distribution_version_parameters
				echo -e $(list_array "available_environments" | sed -e 's@\n@ @g')
				exit 0
			;;
			-ll | --list-locales)
				echo -e "Available locales:\n"$(list_array "available_locales" | sed -e 's@\n@ @g')
				exit 0
			;;
			-lk | --list-keympas)
				echo -e "Available keymaps:\n"$(list_array "available_keymaps" | sed -e 's@\n@ @g')
				exit 0
			;;
			-ln | --list-nvidia)
				if [ -z "${distribution}" ]; then echo "Distribution and version parameters need to be provided."; exit 1; fi
				if [[ ! " ${available_distributions[*]} " =~ " ${distribution} " ]]; then echo -e "Please select a distribution from the below list:"; list_array "available_distributions"; exit 1; fi
				distribution_parameters
				if [[ ! " ${available_versions[*]} " =~ " ${version} " ]]; then echo -e "Please select a version from the below list:"; list_array "available_versions"; exit 1; fi
				distribution_version_parameters
				echo -e ${nvidia_supported}
				exit 0
			;;
			-ls | --list-surface)
				if [ -z "${distribution}" ]; then echo "Distribution and version parameters need to be provided."; exit 1; fi
				if [[ ! " ${available_distributions[*]} " =~ " ${distribution} " ]]; then echo -e "Please select a distribution from the below list:"; list_array "available_distributions"; exit 1; fi
				distribution_parameters
				if [[ ! " ${available_versions[*]} " =~ " ${version} " ]]; then echo -e "Please select a version from the below list:"; list_array "available_versions"; exit 1; fi
				distribution_version_parameters
				echo -e ${surface_supported}
				exit 0
			;;
			-lt | --list-timezones)
				echo -e "Available timezones:\n"$(list_array "available_timezones" | sed -e 's@\n@ @g')
				exit 0
			;;
			-lv | --list-versions)
				if [ -z "${distribution}" ]; then echo "Distribution parameter needs to be provided."; exit 1; fi
				if [[ ! " ${available_distributions[*]} " =~ " ${distribution} " ]]; then echo -e "Please select a distribution from the below list:"; list_array "available_distributions"; exit 1; fi
				distribution_parameters
				echo -e $(list_array "available_versions" | sed -e 's@\n@ @g')
				exit 0
			;;
			-h | --help)
				usage
				exit 0
			;;
			-t | --test)
				test_distribution="Yes"
			;;
			-u | --usb-live)
				live="Yes"
			;;
			*)
				echo "${1} argument is not valid"
				usage
				exit 1
			;;
		esac
		shift
	done
	check_dependencies
	if ! curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/sebanc/linuxloops > /dev/null 2>&1; then echo -e "Internet connection not available, please make sure you are connected to the internet."; exit 1; fi
	cli_installer
fi
