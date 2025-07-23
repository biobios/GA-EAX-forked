#ifndef __KOPT__
#define __KOPT__

#ifndef __RAND__
#include "rand.h"
#endif

#ifndef __Sort__
#include "sort.h"
#endif

#ifndef __INDI__
#include "indi.h"
#endif

#ifndef __EVALUATOR__
#include "evaluator.h"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

class TKopt {
public:
  /**
   * @brief Constructor
   * @param N Number of cities in the TSP instance
   * @details
   * 使用するメモリ領域をあらかじめ確保しておく。
   */
  TKopt( int N );
  ~TKopt();
  /**
   * @brief 近傍リストの逆のリストを構築する
   * @details
   * 自身がほかの都市の近傍50都市に含まれる場合、その都市を記録する
   */
  void SetInvNearList();
  void TransIndiToTree( TIndi& indi );
  void TransTreeToIndi( TIndi& indi );

  void DoIt( TIndi& tIndi );             /* Apply a local search with the 2-opt neighborhood */
  void Sub();
  /**
   * @brief 次の都市を取得する
   * @param t city
   */
  int GetNext( int t );
  /**
   * @brief 前の都市を取得する
   * @param t city
   */
  int GetPrev( int t );
  void IncrementImp( int flagRev );
  void CombineSeg( int segL, int segS );

  void CheckDetail();
  void CheckValid();

  void Swap(int &a,int &b);
  /**
   * @param orient
   * @return 0なら1、1なら0を返す
   */
  int Turn( int &orient );

  /**
   * @brief Set a random tour
   * @param indi The individual to be set with a random tour
   * @details
   * ランダムな巡回路を作成し、距離を評価する。
   */
  void MakeRandSol( TIndi& indi );      /* Set a random tour */


  TEvaluator* eval;

private:
  // Number of cities in the TSP instance
  int fN;

  int fFixNumOfSeg;
  int fNumOfSeg;   
  // 隣接リスト
  int **fLink;     
  // 都市のセグメント番号を記録する
  int *fSegCity;   
  // 各セグメント内での都市の順序を記録する
  int *fOrdCity;   

  int *fOrdSeg;    
  // 各セグメントの向きを記録する
  int *fOrient;    
  // セグメント間のつながりを記録する
  int **fLinkSeg;  
  int *fSizeSeg;   
  // セグメントのはじめとおわりの都市を記録する
  int **fCitySeg;  

  int *fT;
  int fFlagRev;  
  int fTourLength;

  int *fActiveV;
  // Inverse of the near list
  // fInvNearList[c][any]: city c is in the near list of city fInvNearList[c][any]
  int **fInvNearList; 
  // どれだけの都市の近傍50都市に含まれているか
  int *fNumOfINL;     
  
  int *fArray;
  int *fCheckN;
  int *fGene;
  int *fB;
};

#endif

