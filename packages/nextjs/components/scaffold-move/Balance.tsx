import { getFormattedBalanceStr } from "../../utils/scaffold-move/ContentValue/CurrencyValue";
import { useGetAccountNativeBalance } from "~~/hooks/scaffold-move";

type BalanceProps = {
  address: string;
};

export const Balance = ({ address }: BalanceProps) => {
  const { balance, loading, error, nativeTokenSymbol } = useGetAccountNativeBalance(address);

  if (loading) {
    return (
      <div className="animate-pulse flex space-x-4">
        <div className="rounded-md bg-slate-300 h-6 w-6"></div>
        <div className="flex items-center space-y-6">
          <div className="h-2 w-28 bg-slate-300 rounded"></div>
        </div>
      </div>
    );
  }

  if (error || balance === null) {
    return (
      <div className="border-2 border-gray-400 rounded-md px-2 flex flex-col items-center max-w-fit cursor-pointer">
        <div className="text-warning">Error</div>
      </div>
    );
  }

  return (
    <div className="w-full flex items-center justify-center">
      <>
        <span>{getFormattedBalanceStr(balance.toString())}</span>
        <span className="text-[0.8em] font-bold ml-1">{nativeTokenSymbol}</span>
      </>
    </div>
  );
};
