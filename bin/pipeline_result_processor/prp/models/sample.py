"""Data model definition of input/ output data"""
from enum import Enum
from typing import List

from pydantic import Field

from .base import RWModel
from .metadata import RunMetadata
from .phenotype import PhenotypeResult, PhenotypeType
from .qc import QcMethodIndex
from .specie import SpeciesPrediction
from .typing import TypingMethod, TypingResultCgMlst, TypingResultMlst

SAMPLE_ID_PATTERN = r"^[a-zA-Z1-9-_]+$"


class MethodIndex(RWModel):
    type: PhenotypeType | TypingMethod
    result: PhenotypeResult | TypingResultMlst | TypingResultCgMlst


class SampleBase(RWModel):
    """Base datamodel for sample data structure"""

    sample_id: str = Field(
        ..., alias="sampleId", min_length=3, max_length=100, regex=SAMPLE_ID_PATTERN
    )
    run_metadata: RunMetadata = Field(..., alias="runMetadata")
    qc: List[QcMethodIndex] = Field(...)
    species_prediction: SpeciesPrediction = Field(..., alias="speciesPrediction")


class PipelineResult(SampleBase):
    """Input format of sample object from pipeline."""

    schema_version: int = Field(..., alias="schemaVersion", gt=0)
    # optional typing
    typing_result: List[MethodIndex] = Field(..., alias="typingResult")
    # optional phenotype prediction
    phenotype_result: List[MethodIndex] = Field(..., alias="phenotypeResult")