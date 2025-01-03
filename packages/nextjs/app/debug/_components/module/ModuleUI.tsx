"use client";

// @refresh reset
import { ModuleResources } from "./ModuleResources";
import { ModuleViewMethods } from "./ModuleViewMethods";
import { ModuleWriteMethods } from "./ModuleWriteMethods";
import { Address, Balance } from "~~/components/scaffold-move";
import { useDeployedModuleInfo } from "~~/hooks/scaffold-move";
import { useTargetNetwork } from "~~/hooks/scaffold-move/useTargetNetwork";
import { ModuleName } from "~~/utils/scaffold-move/module";

type ModuleUIProps = {
  moduleName: ModuleName;
  className?: string;
};

/**
 * UI component to interface with deployed modules.
 **/
export const ModuleUI = ({ moduleName: moduleName, className = "" }: ModuleUIProps) => {
  const { targetNetwork } = useTargetNetwork();
  const { data: deployedModuleData, isLoading: deployedModuleLoading } = useDeployedModuleInfo(moduleName);
  if (deployedModuleLoading) {
    return (
      <div className="mt-14">
        <span className="loading loading-spinner loading-lg"></span>
      </div>
    );
  }
  if (!deployedModuleData || !deployedModuleData.abi) {
    return (
      <p className="text-3xl mt-14">
        {`No module found by the name of "${String(moduleName)}" on chain "${targetNetwork.id}"!`}
      </p>
    );
  }

  return (
    <div className={`grid grid-cols-1 lg:grid-cols-6 px-6 lg:px-10 lg:gap-12 w-full max-w-7xl my-0 ${className}`}>
      <div className="col-span-5 grid grid-cols-1 lg:grid-cols-3 gap-8 lg:gap-10">
        <div className="col-span-1 flex flex-col">
          <div className="bg-base-100 border-base-300 border shadow-md shadow-secondary rounded-3xl px-6 lg:px-8 mb-6 space-y-1 py-4">
            <div className="flex">
              <div className="flex flex-col gap-1">
                <span className="font-bold">{String(moduleName)}</span>
                <Address address={deployedModuleData.abi.address} />
                <div className="flex gap-1 items-center">
                  <span className="font-bold text-sm">Balance:</span>
                  <Balance address={deployedModuleData.abi.address} />
                </div>
              </div>
            </div>
            {targetNetwork && (
              <p className="my-0 text-sm">
                <span className="font-bold">Network</span>: <span>{String(targetNetwork.name)}</span>
              </p>
            )}
          </div>
        </div>
        <div className="col-span-1 lg:col-span-2 flex flex-col gap-6">
          <div className="z-10">
            <div className="bg-base-100 rounded-3xl shadow-md shadow-secondary border border-base-300 flex flex-col mt-10 relative">
              <div className="h-[5rem] w-[5.5rem] bg-base-300 absolute self-start rounded-[22px] -top-[38px] -left-[1px] -z-10 py-[0.65rem] shadow-lg shadow-base-300">
                <div className="flex items-center justify-center space-x-2">
                  <p className="my-0 text-sm">View</p>
                </div>
              </div>
              <div className="p-5 divide-y divide-base-300">
                <ModuleViewMethods deployedModuleData={deployedModuleData} />
              </div>
            </div>
          </div>
          <div className="z-10">
            <div className="bg-base-100 rounded-3xl shadow-md shadow-secondary border border-base-300 flex flex-col mt-10 relative">
              <div className="h-[5rem] w-[5.5rem] bg-base-300 absolute self-start rounded-[22px] -top-[38px] -left-[1px] -z-10 py-[0.65rem] shadow-lg shadow-base-300">
                <div className="flex items-center justify-center space-x-2">
                  <p className="my-0 text-sm">Run</p>
                </div>
              </div>
              <div className="p-5 divide-y divide-base-300">
                <ModuleWriteMethods deployedModuleData={deployedModuleData} />
              </div>
            </div>
          </div>
          <div className="z-10">
            <div className="bg-base-100 rounded-3xl shadow-md shadow-secondary border border-base-300 flex flex-col mt-10 relative">
              <div className="h-[5rem] w-[5.5rem] bg-base-300 absolute self-start rounded-[22px] -top-[38px] -left-[1px] -z-10 py-[0.65rem] shadow-lg shadow-base-300">
                <div className="flex items-center justify-center space-x-2">
                  <p className="my-0 text-sm">Resources</p>
                </div>
              </div>
              <div className="p-5 divide-y divide-base-300">
                <ModuleResources deployedModuleData={deployedModuleData} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
