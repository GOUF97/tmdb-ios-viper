import os
import uuid
import re

def uid_for(name):
    # Stable 24-character hex ID
    return uuid.uuid5(uuid.NAMESPACE_DNS, name).hex[:24].upper()

def collect_files(directory, ext=(".swift", ".plist", ".xcconfig")):
    file_list = []
    for root, _, files in os.walk(directory):
        for f in sorted(files):
            if any(f.endswith(e) for e in ext):
                full_path = os.path.join(root, f)
                rel_path = os.path.relpath(full_path, directory)
                file_list.append((f, rel_path, full_path))
    return file_list

def update_project():
    app_dir = "MovieDBApp"
    test_dir = "MovieDBAppTests"

    app_files = collect_files(app_dir)
    test_files = collect_files(test_dir)

    proj_id = uid_for("MovieDBApp.project")
    app_target_id = uid_for("MovieDBApp.target")
    test_target_id = uid_for("MovieDBAppTests.target")

    main_group_id = uid_for("MovieDBApp.main_group")
    products_group_id = uid_for("MovieDBApp.products_group")
    app_group_id = uid_for("MovieDBApp.app_group")
    tests_group_id = uid_for("MovieDBApp.tests_group")

    app_product_id = uid_for("MovieDBApp.app_product")
    test_product_id = uid_for("MovieDBApp.test_product")

    app_sources_id = uid_for("MovieDBApp.app_sources")
    app_frameworks_id = uid_for("MovieDBApp.app_frameworks")
    app_resources_id = uid_for("MovieDBApp.app_resources")

    test_sources_id = uid_for("MovieDBApp.test_sources")
    test_frameworks_id = uid_for("MovieDBApp.test_frameworks")
    test_resources_id = uid_for("MovieDBApp.test_resources")

    proj_cfg_list = uid_for("MovieDBApp.proj_cfg_list")
    app_cfg_list = uid_for("MovieDBApp.app_cfg_list")
    test_cfg_list = uid_for("MovieDBApp.test_cfg_list")

    proj_debug_cfg = uid_for("MovieDBApp.proj_debug_cfg")
    proj_release_cfg = uid_for("MovieDBApp.proj_release_cfg")
    app_debug_cfg = uid_for("MovieDBApp.app_debug_cfg")
    app_release_cfg = uid_for("MovieDBApp.app_release_cfg")
    test_debug_cfg = uid_for("MovieDBApp.test_debug_cfg")
    test_release_cfg = uid_for("MovieDBApp.test_release_cfg")

    target_proxy_id = uid_for("MovieDBApp.target_proxy")
    target_dep_id = uid_for("MovieDBApp.target_dep")

    # Generate File refs & build files
    build_files = []
    file_refs = []
    app_group_children = []
    test_group_children = []
    app_source_build_files = []
    test_source_build_files = []

    for fname, rel_path, full_path in app_files:
        f_id = uid_for(f"app_file_{rel_path}")
        file_type = "sourcecode.swift" if fname.endswith(".swift") else ("text.plist.xml" if fname.endswith(".plist") else "text.xcconfig")
        file_refs.append(f"\t\t{f_id} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = \"{rel_path}\"; sourceTree = \"<group>\"; }};")
        app_group_children.append(f"\t\t\t\t{f_id} /* {fname} */,")

        if fname.endswith(".swift"):
            b_id = uid_for(f"app_build_{rel_path}")
            build_files.append(f"\t\t{b_id} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_id} /* {fname} */; }};")
            app_source_build_files.append(f"\t\t\t\t{b_id} /* {fname} in Sources */,")

    for fname, rel_path, full_path in test_files:
        f_id = uid_for(f"test_file_{rel_path}")
        file_type = "sourcecode.swift" if fname.endswith(".swift") else "text.plist.xml"
        file_refs.append(f"\t\t{f_id} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = \"{rel_path}\"; sourceTree = \"<group>\"; }};")
        test_group_children.append(f"\t\t\t\t{f_id} /* {fname} */,")

        if fname.endswith(".swift"):
            b_id = uid_for(f"test_build_{rel_path}")
            build_files.append(f"\t\t{b_id} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_id} /* {fname} */; }};")
            test_source_build_files.append(f"\t\t\t\t{b_id} /* {fname} in Sources */,")

    content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{os.linesep.join(build_files)}
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
		{target_proxy_id} /* PBXContainerItemProxy */ = {{
			isa = PBXContainerItemProxy;
			containerPortal = {proj_id} /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = {app_target_id};
			remoteInfo = MovieDBApp;
		}};
/* End PBXContainerItemProxy section */

/* Begin PBXFileReference section */
		{app_product_id} /* MovieDBApp.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MovieDBApp.app; sourceTree = BUILT_PRODUCTS_DIR; }};
		{test_product_id} /* MovieDBAppTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = MovieDBAppTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};
{os.linesep.join(file_refs)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{app_frameworks_id} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{test_frameworks_id} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{main_group_id} = {{
			isa = PBXGroup;
			children = (
				{app_group_id} /* MovieDBApp */,
				{tests_group_id} /* MovieDBAppTests */,
				{products_group_id} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{products_group_id} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{app_product_id} /* MovieDBApp.app */,
				{test_product_id} /* MovieDBAppTests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
		{app_group_id} /* MovieDBApp */ = {{
			isa = PBXGroup;
			children = (
{os.linesep.join(app_group_children)}
			);
			path = MovieDBApp;
			sourceTree = "<group>";
		}};
		{tests_group_id} /* MovieDBAppTests */ = {{
			isa = PBXGroup;
			children = (
{os.linesep.join(test_group_children)}
			);
			path = MovieDBAppTests;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{app_target_id} /* MovieDBApp */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {app_cfg_list} /* Build configuration list for PBXNativeTarget "MovieDBApp" */;
			buildPhases = (
				{app_sources_id} /* Sources */,
				{app_frameworks_id} /* Frameworks */,
				{app_resources_id} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MovieDBApp;
			productName = MovieDBApp;
			productReference = {app_product_id} /* MovieDBApp.app */;
			productType = "com.apple.product-type.application";
		}};
		{test_target_id} /* MovieDBAppTests */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {test_cfg_list} /* Build configuration list for PBXNativeTarget "MovieDBAppTests" */;
			buildPhases = (
				{test_sources_id} /* Sources */,
				{test_frameworks_id} /* Frameworks */,
				{test_resources_id} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				{target_dep_id} /* PBXTargetDependency */,
			);
			name = MovieDBAppTests;
			productName = MovieDBAppTests;
			productReference = {test_product_id} /* MovieDBAppTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{proj_id} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
				TargetAttributes = {{
					{app_target_id} = {{
						CreatedOnToolsVersion = 16.0;
					}};
					{test_target_id} = {{
						CreatedOnToolsVersion = 16.0;
						TestTargetID = {app_target_id};
					}};
				}};
			}};
			buildConfigurationList = {proj_cfg_list} /* Build configuration list for PBXProject "MovieDBApp" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group_id};
			productRefGroup = {products_group_id} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{app_target_id} /* MovieDBApp */,
				{test_target_id} /* MovieDBAppTests */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{app_resources_id} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{test_resources_id} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{app_sources_id} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{os.linesep.join(app_source_build_files)}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{test_sources_id} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{os.linesep.join(test_source_build_files)}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		{target_dep_id} /* PBXTargetDependency */ = {{
			isa = PBXTargetDependency;
			target = {app_target_id} /* MovieDBApp */;
			targetProxy = {target_proxy_id} /* PBXContainerItemProxy */;
		}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
		{proj_debug_cfg} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
				TMDB_API_KEY = "";
				TMDB_BASE_URL = "api.themoviedb.org";
				TMDB_IMAGE_BASE_URL = "image.tmdb.org/t/p";
			}};
			name = Debug;
		}};
		{proj_release_cfg} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = "wholemodule";
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_VERSION = 5.0;
				TMDB_API_KEY = "";
				TMDB_BASE_URL = "api.themoviedb.org";
				TMDB_IMAGE_BASE_URL = "image.tmdb.org/t/p";
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{app_debug_cfg} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = MovieDBApp/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.enterprise.MovieDBApp;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{app_release_cfg} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = MovieDBApp/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.enterprise.MovieDBApp;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
		{test_debug_cfg} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = MovieDBAppTests/Info.plist;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.enterprise.MovieDBAppTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MovieDBApp.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/MovieDBApp";
			}};
			name = Debug;
		}};
		{test_release_cfg} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = MovieDBAppTests/Info.plist;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.enterprise.MovieDBAppTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MovieDBApp.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/MovieDBApp";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{proj_cfg_list} /* Build configuration list for PBXProject "MovieDBApp" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{proj_debug_cfg} /* Debug */,
				{proj_release_cfg} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{app_cfg_list} /* Build configuration list for PBXNativeTarget "MovieDBApp" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{app_debug_cfg} /* Debug */,
				{app_release_cfg} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{test_cfg_list} /* Build configuration list for PBXNativeTarget "MovieDBAppTests" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{test_debug_cfg} /* Debug */,
				{test_release_cfg} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */

	}};
	rootObject = {proj_id} /* Project object */;
}}
"""
    with open("MovieDBApp.xcodeproj/project.pbxproj", "w") as f:
        f.write(content)

    # Update scheme
    with open("MovieDBApp.xcodeproj/xcshareddata/xcschemes/MovieDBApp.xcscheme", "r") as sf:
        scheme = sf.read()
    scheme = re.sub(r'BlueprintIdentifier = "[0-9A-F]{24}"\s+BuildableName = "MovieDBApp.app"', f'BlueprintIdentifier = "{app_target_id}"\n               BuildableName = "MovieDBApp.app"', scheme)
    scheme = re.sub(r'BlueprintIdentifier = "[0-9A-F]{24}"\s+BuildableName = "MovieDBAppTests.xctest"', f'BlueprintIdentifier = "{test_target_id}"\n               BuildableName = "MovieDBAppTests.xctest"', scheme)
    with open("MovieDBApp.xcodeproj/xcshareddata/xcschemes/MovieDBApp.xcscheme", "w") as sf:
        sf.write(scheme)
    print("Project synced successfully.")

if __name__ == "__main__":
    update_project()
