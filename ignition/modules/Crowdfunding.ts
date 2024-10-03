import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CrowdfundingModule = buildModule("CrowdfundingModule", (m) => {
  const crowdFunding = m.contract("Crowdfunding");

  return { crowdFunding };
});

export default CrowdfundingModule;

// 0x1D6d41FC0860D71E13695395fc1850AC8310b339
