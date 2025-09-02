/**************************************************************************/
/*  register_types.cpp                                                    */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#include "register_types.h"

#include "core/extension/gdextension_interface.h"
#include "core/extension/gdextension_loader.h"
#include "core/extension/gdextension_manager.h"
#include "core/io/config_file.h"
#include "core/object/object.h"
#include "core/object/ref_counted.h"
#include "core/os/shared_object.h"
#include "register_types.h"
#include <functional>

class GDExtensionStaticLibraryLoader : public GDExtensionLoader {
	friend class GDExtensionManager;
	friend class GDExtension;

private:
	void *entry_funcptr = nullptr;
	String library_path;

public:
	void set_entry_funcptr(void *p_entry_funcptr) {
		entry_funcptr = p_entry_funcptr;
	}
	virtual Error open_library(const String &p_path) override {
		library_path = p_path;
		return OK;
	}
	virtual Error
	initialize(GDExtensionInterfaceGetProcAddress p_get_proc_address,
			const Ref<GDExtension> &p_extension,
			GDExtensionInitialization *r_initialization) override {
		GDExtensionInitializationFunction initialization_function =
				(GDExtensionInitializationFunction)entry_funcptr;
		if (initialization_function == nullptr) {
			ERR_PRINT("GDExtension initialization function '" + library_path +
					"' is null.");
			return FAILED;
		}
		GDExtensionBool ret = initialization_function(
				p_get_proc_address, p_extension.ptr(), r_initialization);

		if (ret) {
			return OK;
		} else {
			ERR_PRINT("GDExtension initialization function '" + library_path +
					"' returned an error.");
			return FAILED;
		}
	}
	virtual void close_library() override {}
	virtual bool is_library_open() const override { return true; }
	virtual bool has_library_changed() const override { return false; }
	virtual bool library_exists() const override { return true; }
};

extern "C" {
GDExtensionBool
gdext_rust_init(GDExtensionInterfaceGetProcAddress p_get_proc_address,
		GDExtensionClassLibraryPtr p_library,
		GDExtensionInitialization *r_initialization);
}

void initialize_godot_wry_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SERVERS) {
		return;
	}
	if (Engine::get_singleton()->is_project_manager_hint()) {
		return;
	}

	Ref<GDExtensionStaticLibraryLoader> loader;
	loader.instantiate();
	loader->set_entry_funcptr((void *)&gdext_rust_init);
	GDExtensionManager::get_singleton()->load_extension_with_loader("godot_wry",
			loader);
}

void uninitialize_godot_wry_module(ModuleInitializationLevel p_level) {
	// Nothing to do here
}
