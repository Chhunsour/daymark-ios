#!/usr/bin/env python3
import os
import hashlib
from pathlib import Path

def uid(name: str) -> str:
    h = hashlib.md5(name.encode('utf-8')).hexdigest().upper()
    return h[:24]

def main():
    root_dir = Path(__file__).resolve().parent.parent
    daymark_dir = root_dir / "Daymark"
    tests_dir = root_dir / "DaymarkTests"

    # Find all source and resource files
    app_swift_files = sorted(list(daymark_dir.rglob("*.swift")))
    test_swift_files = sorted(list(tests_dir.rglob("*.swift")))
    xcassets_dirs = sorted(list(daymark_dir.rglob("*.xcassets")))

    proj_uid = uid("DAYMARK_PROJECT")
    main_group_uid = uid("MAIN_GROUP")
    products_group_uid = uid("PRODUCTS_GROUP")
    daymark_group_uid = uid("DAYMARK_GROUP")
    tests_group_uid = uid("TESTS_GROUP")

    app_target_uid = uid("DAYMARK_APP_TARGET")
    tests_target_uid = uid("DAYMARK_TESTS_TARGET")

    app_product_uid = uid("DAYMARK_APP_PRODUCT")
    tests_product_uid = uid("DAYMARK_TESTS_PRODUCT")

    app_sources_build_phase_uid = uid("APP_SOURCES_BUILD_PHASE")
    app_resources_build_phase_uid = uid("APP_RESOURCES_BUILD_PHASE")
    app_frameworks_build_phase_uid = uid("APP_FRAMEWORKS_BUILD_PHASE")

    tests_sources_build_phase_uid = uid("TESTS_SOURCES_BUILD_PHASE")
    tests_resources_build_phase_uid = uid("TESTS_RESOURCES_BUILD_PHASE")
    tests_frameworks_build_phase_uid = uid("TESTS_FRAMEWORKS_BUILD_PHASE")

    target_dep_uid = uid("TESTS_TARGET_DEP")
    container_proxy_uid = uid("CONTAINER_PROXY")

    # Configs
    proj_config_list_uid = uid("PROJ_CONFIG_LIST")
    proj_debug_config_uid = uid("PROJ_DEBUG_CONFIG")
    proj_release_config_uid = uid("PROJ_RELEASE_CONFIG")

    app_config_list_uid = uid("APP_CONFIG_LIST")
    app_debug_config_uid = uid("APP_DEBUG_CONFIG")
    app_release_config_uid = uid("APP_RELEASE_CONFIG")

    tests_config_list_uid = uid("TESTS_CONFIG_LIST")
    tests_debug_config_uid = uid("TESTS_DEBUG_CONFIG")
    tests_release_config_uid = uid("TESTS_RELEASE_CONFIG")

    build_files = []
    file_refs = []
    app_sources_entries = []
    app_resources_entries = []
    tests_sources_entries = []

    # Map for groups
    # Group structure: Daymark group contains subdirectories
    def rel_to_root(p: Path) -> str:
        return str(p.relative_to(root_dir))

    # App swift files
    app_file_uids = []
    for f in app_swift_files:
        rel_path = rel_to_root(f)
        f_ref_uid = uid(f"FILEREF_{rel_path}")
        b_file_uid = uid(f"BUILDFILE_{rel_path}")
        file_refs.append(f"\t\t{f_ref_uid} /* {f.name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{f.name}\"; sourceTree = \"<group>\"; }};")
        build_files.append(f"\t\t{b_file_uid} /* {f.name} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_ref_uid}; }};")
        app_sources_entries.append(f"\t\t\t\t{b_file_uid} /* {f.name} in Sources */,")
        app_file_uids.append((f, f_ref_uid))

    # App xcassets
    for a in xcassets_dirs:
        rel_path = rel_to_root(a)
        f_ref_uid = uid(f"FILEREF_{rel_path}")
        b_file_uid = uid(f"BUILDFILE_{rel_path}")
        file_refs.append(f"\t\t{f_ref_uid} /* {a.name} */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = \"{a.name}\"; sourceTree = \"<group>\"; }};")
        build_files.append(f"\t\t{b_file_uid} /* {a.name} in Resources */ = {{isa = PBXBuildFile; fileRef = {f_ref_uid}; }};")
        app_resources_entries.append(f"\t\t\t\t{b_file_uid} /* {a.name} in Resources */,")
        app_file_uids.append((a, f_ref_uid))

    # Test swift files
    tests_file_uids = []
    for f in test_swift_files:
        rel_path = rel_to_root(f)
        f_ref_uid = uid(f"FILEREF_{rel_path}")
        b_file_uid = uid(f"BUILDFILE_{rel_path}")
        file_refs.append(f"\t\t{f_ref_uid} /* {f.name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{f.name}\"; sourceTree = \"<group>\"; }};")
        build_files.append(f"\t\t{b_file_uid} /* {f.name} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_ref_uid}; }};")
        tests_sources_entries.append(f"\t\t\t\t{b_file_uid} /* {f.name} in Sources */,")
        tests_file_uids.append((f, f_ref_uid))

    # Product file refs
    file_refs.append(f"\t\t{app_product_uid} /* Daymark.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Daymark.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
    file_refs.append(f"\t\t{tests_product_uid} /* DaymarkTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = DaymarkTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};")

    # Build directory group tree for Daymark
    def build_group_tree(base_path: Path, items):
        # items: list of (Path, uid)
        # Returns PBXGroup definitions string and base_group_uid
        groups = {}
        # Find all subdirs
        subdirs = set()
        for p, u in items:
            cur = p.parent
            while cur != base_path and cur != base_path.parent:
                subdirs.add(cur)
                cur = cur.parent

        # Base group
        all_dirs = sorted(list(subdirs), key=lambda d: len(d.parts))
        
        # Build children map
        dir_children = {d: [] for d in [base_path] + all_dirs}
        for d in all_dirs:
            parent = d.parent
            if parent in dir_children:
                dir_children[parent].append(d)

        for p, u in items:
            parent = p.parent
            if parent in dir_children:
                dir_children[parent].append((p, u))

        group_blocks = []
        for d in [base_path] + all_dirs:
            g_uid = uid(f"GROUP_{rel_to_root(d)}")
            children_lines = []
            for item in dir_children[d]:
                if isinstance(item, Path):
                    child_g_uid = uid(f"GROUP_{rel_to_root(item)}")
                    children_lines.append(f"\t\t\t\t{child_g_uid} /* {item.name} */,")
                else:
                    item_path, item_uid = item
                    children_lines.append(f"\t\t\t\t{item_uid} /* {item_path.name} */,")
            
            name_attr = f"path = \"{d.name}\"; " if d != root_dir else ""
            group_blocks.append(f"""\t\t{g_uid} /* {d.name} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(children_lines)}
\t\t\t);
\t\t\t{name_attr}sourceTree = "<group>";
\t\t}};""")

        return "\n".join(group_blocks), uid(f"GROUP_{rel_to_root(base_path)}")

    app_groups_str, app_main_group_uid = build_group_tree(daymark_dir, app_file_uids)
    tests_groups_str, tests_main_group_uid = build_group_tree(tests_dir, tests_file_uids)

    pbxproj_content = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_files)}
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
\t\t{container_proxy_uid} /* PBXContainerItemProxy */ = {{
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = {proj_uid} /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = {app_target_uid};
\t\t\tremoteInfo = Daymark;
\t\t}};
/* End PBXContainerItemProxy section */

/* Begin PBXFileReference section */
{chr(10).join(file_refs)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{app_frameworks_build_phase_uid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{tests_frameworks_build_phase_uid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{main_group_uid} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_main_group_uid} /* Daymark */,
\t\t\t\t{tests_main_group_uid} /* DaymarkTests */,
\t\t\t\t{products_group_uid} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{products_group_uid} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_product_uid} /* Daymark.app */,
\t\t\t\t{tests_product_uid} /* DaymarkTests.xctest */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
{app_groups_str}
{tests_groups_str}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{app_target_uid} /* Daymark */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {app_config_list_uid} /* Build configuration list for PBXNativeTarget "Daymark" */;
\t\t\tbuildPhases = (
\t\t\t\t{app_sources_build_phase_uid} /* Sources */,
\t\t\t\t{app_frameworks_build_phase_uid} /* Frameworks */,
\t\t\t\t{app_resources_build_phase_uid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = Daymark;
\t\t\tproductName = Daymark;
\t\t\tproductReference = {app_product_uid} /* Daymark.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
\t\t{tests_target_uid} /* DaymarkTests */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {tests_config_list_uid} /* Build configuration list for PBXNativeTarget "DaymarkTests" */;
\t\t\tbuildPhases = (
\t\t\t\t{tests_sources_build_phase_uid} /* Sources */,
\t\t\t\t{tests_frameworks_build_phase_uid} /* Frameworks */,
\t\t\t\t{tests_resources_build_phase_uid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t{target_dep_uid} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = DaymarkTests;
\t\t\tproductName = DaymarkTests;
\t\t\tproductReference = {tests_product_uid} /* DaymarkTests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.unit-test";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{proj_uid} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastUpgradeCheck = 2700;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{app_target_uid} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t\t{tests_target_uid} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t\tTestTargetID = {app_target_uid};
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {proj_config_list_uid} /* Build configuration list for PBXProject "Daymark" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_group_uid};
\t\t\tproductRefGroup = {products_group_uid} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{app_target_uid} /* Daymark */,
\t\t\t\t{tests_target_uid} /* DaymarkTests */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{app_resources_build_phase_uid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(app_resources_entries)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{tests_resources_build_phase_uid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{app_sources_build_phase_uid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(app_sources_entries)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{tests_sources_build_phase_uid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(tests_sources_entries)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
\t\t{target_dep_uid} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = {app_target_uid} /* Daymark */;
\t\t\ttargetProxy = {container_proxy_uid} /* PBXContainerItemProxy */;
\t\t}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
\t\t{proj_debug_config_uid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSUPPORTS_MACCATALYST = NO;
\t\t\t\tSUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{proj_release_config_uid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSUPPORTS_MACCATALYST = NO;
\t\t\t\tSUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{app_debug_config_uid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_IDENTITY = "-";
\t\t\t\tCODE_SIGN_STYLE = Manual;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = Daymark;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.chhunsour.Daymark;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{app_release_config_uid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_IDENTITY = "-";
\t\t\t\tCODE_SIGN_STYLE = Manual;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = Daymark;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.chhunsour.Daymark;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{tests_debug_config_uid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";
\t\t\t\tCODE_SIGN_IDENTITY = "-";
\t\t\t\tCODE_SIGN_STYLE = Manual;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.chhunsour.DaymarkTests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = NO;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tTEST_HOST = "$(BUILT_PRODUCTS_DIR)/Daymark.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Daymark";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{tests_release_config_uid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";
\t\t\t\tCODE_SIGN_IDENTITY = "-";
\t\t\t\tCODE_SIGN_STYLE = Manual;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.chhunsour.DaymarkTests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = NO;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tTEST_HOST = "$(BUILT_PRODUCTS_DIR)/Daymark.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Daymark";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{proj_config_list_uid} /* Build configuration list for PBXProject "Daymark" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{proj_debug_config_uid} /* Debug */,
\t\t\t\t{proj_release_config_uid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{app_config_list_uid} /* Build configuration list for PBXNativeTarget "Daymark" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{app_debug_config_uid} /* Debug */,
\t\t\t\t{app_release_config_uid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{tests_config_list_uid} /* Build configuration list for PBXNativeTarget "DaymarkTests" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{tests_debug_config_uid} /* Debug */,
\t\t\t\t{tests_release_config_uid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */

\t}};
\trootObject = {proj_uid} /* Project object */;
}}
"""

    xcodeproj_dir = root_dir / "Daymark.xcodeproj"
    xcodeproj_dir.mkdir(parents=True, exist_ok=True)
    
    with open(xcodeproj_dir / "project.pbxproj", "w", encoding="utf-8") as f:
        f.write(pbxproj_content)

    # Scheme
    shared_data = xcodeproj_dir / "xcshareddata" / "xcschemes"
    shared_data.mkdir(parents=True, exist_ok=True)

    scheme_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "2700"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{app_target_uid}"
               BuildableName = "Daymark.app"
               BlueprintName = "Daymark"
               ReferencedContainer = "container:Daymark.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "NO"
            buildForProfiling = "NO"
            buildForArchiving = "NO"
            buildForAnalyzing = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{tests_target_uid}"
               BuildableName = "DaymarkTests.xctest"
               BlueprintName = "DaymarkTests"
               ReferencedContainer = "container:Daymark.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{tests_target_uid}"
               BuildableName = "DaymarkTests.xctest"
               BlueprintName = "DaymarkTests"
               ReferencedContainer = "container:Daymark.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useRelativeToCommandLineArgument = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_uid}"
            BuildableName = "Daymark.app"
            BlueprintName = "Daymark"
            ReferencedContainer = "container:Daymark.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useRelativeToCommandLineArgument = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_uid}"
            BuildableName = "Daymark.app"
            BlueprintName = "Daymark"
            ReferencedContainer = "container:Daymark.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
    with open(shared_data / "Daymark.xcscheme", "w", encoding="utf-8") as f:
        f.write(scheme_content)

    # Workspace
    workspace_dir = xcodeproj_dir / "project.xcworkspace"
    workspace_dir.mkdir(parents=True, exist_ok=True)
    with open(workspace_dir / "contents.xcworkspacedata", "w", encoding="utf-8") as f:
        f.write("""<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:Daymark.xcodeproj">
   </FileRef>
</Workspace>
""")

    print(f"Generated Daymark.xcodeproj successfully with {len(app_swift_files)} app files and {len(test_swift_files)} test files.")

if __name__ == "__main__":
    main()
