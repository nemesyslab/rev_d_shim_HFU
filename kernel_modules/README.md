# Kernel modules

To build custom kernel modules, you first need to build the kernel itself. Please refer to the [snickerdoodle_src README](../snickerdoodle_src/README.md) for instructions on how to build the kernel.

Once the kernel is built, you can build the kernel modules by running the following command:

```bash
./build-kernel.sh <MODULE DIRECTORY>
```

Where `<MODULE DIRECTORY>` is the directory containing the module you wish to build. This will build the module to a `.ko` file in the module directory.